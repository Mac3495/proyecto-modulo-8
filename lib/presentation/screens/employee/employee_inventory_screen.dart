import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_modulo/data/models/product/product_subsidiary_model.dart';
import 'package:proyecto_modulo/presentation/screens/cart/cart_screen.dart';
import '../../../core/app_bloc/app_user_cubit.dart';
import '../../../data/models/product/product_model.dart';
import '../../../data/models/subsidiary/subsidiary_model.dart';
import '../../../data/services/product/product_service_impl.dart';
import '../../../data/services/subsidiary/subsidiary_service_impl.dart';

class EmployeeInventoryScreen extends StatefulWidget {
  const EmployeeInventoryScreen({super.key});

  @override
  State<EmployeeInventoryScreen> createState() => _EmployeeInventoryScreenState();
}

class _EmployeeInventoryScreenState extends State<EmployeeInventoryScreen> {
  final _productService = ProductServiceImpl();
  final _subsidiaryService = SubsidiaryServiceImpl();
  final _searchController = TextEditingController();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<Map<String, dynamic>> _cart = []; // 🔹 Carrito de productos seleccionados
  bool _isLoading = true;
  SubsidiaryModel? _employeeSubsidiary;

  @override
  void initState() {
    super.initState();
    _loadInventoryForEmployee();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventoryForEmployee() async {
    try {
      final user = context.read<AppUserCubit>().state.user;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final subsidiaries = await _subsidiaryService.getAllSubsidiaries();
      if (!mounted) return;

      final assignedSubsidiary = subsidiaries.firstWhere(
        (s) => s.employeeId == user.userId,
        orElse:
            () =>
                const SubsidiaryModel(subsidiaryId: '', name: '', isOpen: false, employeeId: null),
      );

      if (assignedSubsidiary.subsidiaryId.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;
      setState(() {
        _employeeSubsidiary = assignedSubsidiary;
      });

      await _loadProducts(assignedSubsidiary.subsidiaryId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('❌ Error al cargar inventario: $e');
    }
  }

  Future<void> _loadProducts(String subsidiaryId) async {
    try {
      final allProducts = await _productService.getAllProducts();
      if (!mounted) return;

      final filtered =
          allProducts.where((p) {
            final match = p.subsidiaries.firstWhere(
              (ps) => ps.subsidiaryId == subsidiaryId,
              orElse: () => ProductSubsidiary(subsidiaryId: '', quantity: 0),
            );
            return match.quantity > 0;
          }).toList();

      if (!mounted) return;
      setState(() {
        _allProducts = filtered;
        _filteredProducts = filtered;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('❌ Error al cargar productos: $e');
    }
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts =
            _allProducts.where((p) => p.name.toLowerCase().contains(query)).toList();
      }
    });
  }

  /// 🔹 Agregar producto al carrito
  void _addToCart(ProductModel product, int quantity) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item['id'] == product.productId);
      if (existingIndex >= 0) {
        _cart[existingIndex]['quantity'] += quantity;
      } else {
        _cart.add({
          'id': product.productId,
          'name': product.name,
          'price': product.price,
          'quantity': quantity,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 🔹 Mostrar bottomSheet para ingresar cantidad
  void _showSellBottomSheet(ProductModel product, int stock) {
    final quantityController = TextEditingController();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Precio unitario: Bs ${product.price.toStringAsFixed(2)}'),
              Text('Stock disponible: $stock'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad a vender',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Agregar al carrito'),
                  onPressed: () {
                    final qty = int.tryParse(quantityController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Por favor ingresa una cantidad válida.')),
                      );
                      return;
                    }
                    if (qty > stock) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Cantidad superior al stock disponible.')),
                      );
                      return;
                    }

                    _addToCart(product, qty);
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

  @override
  Widget build(BuildContext context) {
    final subsidiaryName = _employeeSubsidiary?.name ?? 'Sin sucursal asignada';
    final cartCount = _cart.fold<int>(0, (sum, item) => sum + item['quantity'] as int);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario - $subsidiaryName'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartScreen(cartItems: _cart)),
                  );

                  if (result != null && result is List<Map<String, dynamic>>) {
                    setState(() => _cart = result);
                  }
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredProducts.isEmpty
              ? const Center(
                child: Text(
                  'No hay productos disponibles.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar producto...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredProducts.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final ps = product.subsidiaries.firstWhere(
                          (ps) => ps.subsidiaryId == _employeeSubsidiary!.subsidiaryId,
                          orElse: () => ProductSubsidiary(subsidiaryId: '', quantity: 0),
                        );

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text('Precio: Bs ${product.price.toStringAsFixed(2)}'),
                                Text('Stock disponible: ${ps.quantity}'),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.point_of_sale),
                                    label: const Text('Vender'),
                                    onPressed: () => _showSellBottomSheet(product, ps.quantity),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
