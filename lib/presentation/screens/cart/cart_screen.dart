import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/sale/sale_model.dart';
import '../../../data/models/sale/sale_product_model.dart';
import '../../../data/services/sale/sale_service_impl.dart';
import '../../../data/services/subsidiary/subsidiary_service_impl.dart';
import '../bill/bill_screen.dart';
import '../../../core/app_bloc/app_user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cart;
  bool _isProcessing = false;

  final _saleService = SaleServiceImpl();
  final _subsidiaryService = SubsidiaryServiceImpl();

  @override
  void initState() {
    super.initState();
    _cart = List<Map<String, dynamic>>.from(widget.cartItems);
  }

  double get totalPrice =>
      _cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  /// 🔹 Editar cantidad de un producto del carrito
  void _editQuantity(Map<String, dynamic> product) {
    final controller = TextEditingController(text: product['quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar cantidad - ${product['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nueva cantidad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar cambios'),
                  onPressed: () {
                    final newQty = int.tryParse(controller.text) ?? 0;
                    if (newQty <= 0) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Cantidad no válida')),
                      );
                      return;
                    }
                    setState(() {
                      final index = _cart.indexWhere((item) => item['id'] == product['id']);
                      if (index >= 0) _cart[index]['quantity'] = newQty;
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Eliminar producto del carrito
  void _removeItem(String productId) {
    setState(() => _cart.removeWhere((item) => item['id'] == productId));
  }

  /// 🔹 Procesar venta y guardar en Firebase
  Future<void> _processSale() async {
    if (_cart.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final user = context.read<AppUserCubit>().state.user;
      if (user == null) throw Exception('Usuario no autenticado.');

      final subsidiaries = await _subsidiaryService.getAllSubsidiaries();
      final subsidiary = subsidiaries.firstWhere(
        (s) => s.employeeId == user.userId,
        orElse: () => throw Exception('No tienes una sucursal asignada.'),
      );

      final saleProducts = _cart.map((item) {
        return SaleProduct(
          productId: item['id'],
          name: item['name'],
          quantity: item['quantity'],
          price: item['price'],
        );
      }).toList();

      final sale = SaleModel(
        saleId: '',
        subsidiaryId: subsidiary.subsidiaryId,
        products: saleProducts,
        date: DateTime.now(),
        clientCode: 'C-${DateTime.now().millisecondsSinceEpoch}',
      );

      await _saleService.createSale(sale);

      // 🔹 Actualizar stock
      for (final item in _cart) {
        await _updateProductStock(
          productId: item['id'],
          soldQuantity: item['quantity'],
          subsidiaryId: subsidiary.subsidiaryId,
        );
      }

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _cart.clear();
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BillScreen(sale: sale)),
      );
    } catch (e) {
      debugPrint('❌ Error al procesar venta: $e');
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar venta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

/// 🔹 Actualiza el stock total y por sucursal (usando el campo correcto: subsidiaries)
Future<void> _updateProductStock({
  required String productId,
  required int soldQuantity,
  required String subsidiaryId,
}) async {
  final docRef = FirebaseFirestore.instance.collection('product').doc(productId);
  final docSnap = await docRef.get();

  if (!docSnap.exists) {
    debugPrint('⚠️ Producto no encontrado en la colección: $productId');
    return;
  }

  final data = docSnap.data()!;
  int totalQuantity = (data['quantity'] ?? 0) - soldQuantity;
  if (totalQuantity < 0) totalQuantity = 0;

  // 🔹 Asegurar lista válida de 'subsidiaries'
  final List<dynamic> rawList = (data['subsidiaries'] ?? []) as List<dynamic>;
  final List<Map<String, dynamic>> subsidiariesList =
      rawList.map((e) => Map<String, dynamic>.from(e)).toList();

  final index = subsidiariesList.indexWhere((s) => s['subsidiaryId'] == subsidiaryId);

  if (index >= 0) {
    // 🔹 Si existe la sucursal, descontar cantidad
    final currentQty = subsidiariesList[index]['quantity'] ?? 0;
    final updatedQty = (currentQty - soldQuantity) < 0 ? 0 : currentQty - soldQuantity;
    subsidiariesList[index]['quantity'] = updatedQty;
  } else {
    // 🔹 Si no existe el registro de sucursal, agregarlo con cantidad 0
    subsidiariesList.add({
      'subsidiaryId': subsidiaryId,
      'quantity': 0,
    });
  }

  // 🔹 Actualizar en Firestore
  await docRef.update({
    'quantity': totalQuantity,
    'subsidiaries': subsidiariesList,
  });

  debugPrint('✅ Stock actualizado correctamente para producto $productId');
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de venta')),
      body: _cart.isEmpty
          ? const Center(
              child: Text(
                'El carrito está vacío.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final product = _cart[index];
                      final subtotal = product['price'] * product['quantity'];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Info del producto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Precio: Bs ${product['price']}'),
                                    Text('Cantidad: ${product['quantity']}'),
                                    Text(
                                      'Subtotal: Bs ${subtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 🔹 Acciones (editar y eliminar)
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Editar cantidad',
                                    onPressed: () => _editQuantity(product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Eliminar producto',
                                    onPressed: () => _removeItem(product['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 🔹 Total + Botón de venta
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Bs ${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: Text(_isProcessing ? 'Procesando venta...' : 'Realizar venta'),
                          onPressed: _isProcessing ? null : _processSale,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
