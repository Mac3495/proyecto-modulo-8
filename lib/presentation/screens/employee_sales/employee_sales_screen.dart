import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_bloc/app_user_cubit.dart';
import '../../../data/models/sale/sale_model.dart';
import '../../../data/models/sale/sale_product_model.dart';
import '../../../data/services/subsidiary/subsidiary_service_impl.dart';
import '../bill/bill_screen.dart';

class EmployeeSalesScreen extends StatefulWidget {
  const EmployeeSalesScreen({super.key});

  @override
  State<EmployeeSalesScreen> createState() => _EmployeeSalesScreenState();
}

class _EmployeeSalesScreenState extends State<EmployeeSalesScreen> {
  final _subsidiaryService = SubsidiaryServiceImpl();
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<SaleModel> _sales = [];

  @override
  void initState() {
    super.initState();
    _loadSalesForEmployee();
  }

  Future<void> _loadSalesForEmployee() async {
    try {
      final user = context.read<AppUserCubit>().state.user;
      if (user == null) return;

      final subsidiaries = await _subsidiaryService.getAllSubsidiaries();
      final subsidiary = subsidiaries.firstWhere(
        (s) => s.employeeId == user.userId,
        orElse: () => throw Exception('No tienes una sucursal asignada.'),
      );

      final snapshot = await _firestore
          .collection('sales')
          .where('subsidiaryId', isEqualTo: subsidiary.subsidiaryId)
          .orderBy('date', descending: true)
          .get();

      final loadedSales = snapshot.docs.map((doc) {
        final data = doc.data();
        final products = (data['products'] as List<dynamic>)
            .map((p) => SaleProduct.fromMap(Map<String, dynamic>.from(p)))
            .toList();
        return SaleModel(
          saleId: doc.id,
          subsidiaryId: data['subsidiaryId'],
          products: products,
          date: data['date'] is Timestamp
    ? (data['date'] as Timestamp).toDate()
    : DateTime.parse(data['date'].toString()),
          clientCode: data['clientCode'],
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _sales = loadedSales;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando ventas: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  double _calculateTotal(SaleModel sale) {
    return sale.products.fold(0, (sum, p) => sum + (p.price * p.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ventas'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
              ? const Center(
                  child: Text(
                    'No se han registrado ventas en tu sucursal.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSalesForEmployee,
                  child: ListView.builder(
                    itemCount: _sales.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final sale = _sales[index];
                      final total = _calculateTotal(sale);
                      final formattedDate =
                          "${sale.date.day.toString().padLeft(2, '0')}/${sale.date.month.toString().padLeft(2, '0')}/${sale.date.year} "
                          "${sale.date.hour.toString().padLeft(2, '0')}:${sale.date.minute.toString().padLeft(2, '0')}";

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            'Cliente: ${sale.clientCode}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha: $formattedDate'),
                              Text('Productos: ${sale.products.length}'),
                              const SizedBox(height: 4),
                              Text(
                                'Total: Bs ${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.receipt_long_outlined,
                              color: Colors.blueGrey),
                          onTap: () {
                            // 🔹 Mostrar factura sin botón de retorno
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BillScreen(
                                  sale: sale,
                                  showBackButton: false,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
