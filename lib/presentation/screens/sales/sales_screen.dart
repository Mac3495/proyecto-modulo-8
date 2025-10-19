import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/sale/sale_model.dart';
import '../../../data/models/subsidiary/subsidiary_model.dart';
import '../../../data/services/subsidiary/subsidiary_service_impl.dart';
import '../../modules/sales/sale_bloc.dart';
import '../../modules/sales/sale_event.dart';
import '../../modules/sales/sale_state.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _subsidiaryService = SubsidiaryServiceImpl();
  late final SaleBloc _saleBloc;
  List<SubsidiaryModel> _subsidiaries = [];
  SubsidiaryModel? _selectedSubsidiary;

  @override
  void initState() {
    super.initState();
    _saleBloc = SaleBloc();
    _loadSubsidiaries();
  }

  Future<void> _loadSubsidiaries() async {
    final list = await _subsidiaryService.getAllSubsidiaries();
    if (!mounted) return;

    setState(() {
      _subsidiaries = list;
      if (list.isNotEmpty) _selectedSubsidiary = list.first;
    });

    if (_selectedSubsidiary != null) {
      _saleBloc.add(LoadSalesBySubsidiary(_selectedSubsidiary!.subsidiaryId));
    }
  }

  @override
  void dispose() {
    _saleBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _saleBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Ventas por Sucursal')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubsidiarySelector(),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SaleBloc, SaleState>(
                  builder: (context, state) {
                    if (state.isLoading && state.sales.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.errorMessage != null) {
                      return Center(
                        child: Text(
                          'Error: ${state.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (state.sales.isEmpty) {
                      return const Center(
                        child: Text('No hay ventas registradas.'),
                      );
                    }

                    // 🔹 Calcular total general de la sucursal
                    final totalIngresos = state.sales.fold<double>(
                      0,
                      (sum, sale) => sum + sale.totalAmount,
                    );

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.sales.length,
                            itemBuilder: (context, index) {
                              final sale = state.sales[index];
                              return _buildSaleCard(sale);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTotalCard(totalIngresos),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubsidiarySelector() {
    if (_subsidiaries.isEmpty) {
      return const Text(
        'No hay sucursales disponibles',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Row(
      children: [
        const Text(
          'Sucursal:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<SubsidiaryModel>(
            value: _selectedSubsidiary,
            isExpanded: true,
            items: _subsidiaries
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name),
                  ),
                )
                .toList(),
            onChanged: (newValue) {
              if (newValue == null) return;
              setState(() => _selectedSubsidiary = newValue);
              _saleBloc.add(LoadSalesBySubsidiary(newValue.subsidiaryId));
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaleCard(SaleModel sale) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final total = sale.totalAmount.toStringAsFixed(2);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Cliente y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cliente: ${sale.clientCode}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  dateFormat.format(sale.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),

            // 🔹 Productos vendidos
            ...sale.products.map((p) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(p.name)),
                      Text('${p.quantity} x ${p.price.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: Bs $total',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double totalIngresos) {
    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total de ingresos:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Bs ${totalIngresos.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
