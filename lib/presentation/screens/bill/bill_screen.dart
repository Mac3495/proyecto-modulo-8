import 'package:flutter/material.dart';
import 'package:proyecto_modulo/presentation/screens/employee_home/employee_home_screen.dart';
import '../../../data/models/sale/sale_model.dart';

class BillScreen extends StatelessWidget {
  final SaleModel sale;
  final bool showBackButton;

  const BillScreen({super.key, required this.sale, this.showBackButton = true});

  double get totalAmount => sale.products.fold(0, (sum, p) => sum + (p.price * p.quantity));

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${sale.date.day.toString().padLeft(2, '0')}/${sale.date.month.toString().padLeft(2, '0')}/${sale.date.year} "
        "${sale.date.hour.toString().padLeft(2, '0')}:${sale.date.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Comprobante de Venta'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🧾 Encabezado del recibo
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'RECIBO DE VENTA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Código del cliente: ${sale.clientCode}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Sucursal ID: ${sale.subsidiaryId}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Fecha: $formattedDate',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1.2),

                // 📋 Detalle de productos
                Expanded(
                  child: ListView.separated(
                    itemCount: sale.products.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final p = sale.products[index];
                      final subtotal = p.price * p.quantity;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(p.name, style: const TextStyle(fontSize: 15)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'x${p.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Bs ${p.price.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Bs ${subtotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Divider(thickness: 1.2),
                const SizedBox(height: 8),

                // 💰 Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Bs ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔁 Botón volver al inventario
                if (showBackButton)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      'Volver al inventario',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueGrey.shade700,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
