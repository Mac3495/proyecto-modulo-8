import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product/product_model.dart';
import '../../../data/models/product/product_subsidiary_model.dart';
import '../../../data/models/subsidiary/subsidiary_model.dart';
import '../../../data/services/subsidiary/subsidiary_service_impl.dart';
import '../../modules/products/product_bloc.dart';
import '../../modules/products/product_event.dart';
import '../../modules/products/product_state.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc()..add(LoadProducts()),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  final _subsidiaryService = SubsidiaryServiceImpl();
  List<SubsidiaryModel> _subsidiaries = [];

  @override
  void initState() {
    super.initState();
    _loadSubsidiaries();
  }

  Future<void> _loadSubsidiaries() async {
  final list = await _subsidiaryService.getAllSubsidiaries();
  if (!mounted) return; // ✅ evita error si el widget fue desmontado
  setState(() {
    _subsidiaries = list;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Productos')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state.products.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Nombre del producto
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🔹 Cantidad y precio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cantidad total: ${product.quantity}'),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Divider(),

                      // 🔹 Sucursales donde se encuentra
                      const Text(
                        'Sucursales asignadas:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 6),

                      if (product.subsidiaries.isEmpty)
                        const Text(
                          'Sin asignar',
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: product.subsidiaries.map((s) {
                            final sub = _subsidiaries.firstWhere(
                              (subs) => subs.subsidiaryId == s.subsidiaryId,
                              orElse: () => SubsidiaryModel(
                                  subsidiaryId: s.subsidiaryId,
                                  name: 'Sucursal desconocida',
                                  isOpen: true,
                                  employeeId: null),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                '• ${sub.name} → ${s.quantity} unidades',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 14),

                      // 🔹 Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            label: const Text('Editar'),
                            onPressed: () =>
                                _showEditProductSheet(context, product),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.store, color: Colors.green),
                            label: const Text('Asignar'),
                            onPressed: () =>
                                _showAssignToSubsidiarySheet(context, product),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔹 BottomSheet para agregar producto
  void _showAddProductSheet(BuildContext context) {

    final bloc = context.read<ProductBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: _ProductForm(
              title: 'Agregar producto',
              buttonText: 'Guardar producto',
              onSubmit: (name, qty, price) {
                final newProduct = ProductModel(
                  productId: '',
                  name: name,
                  quantity: qty,
                  price: price,
                  subsidiaries: const [],
                );
                bloc.add(AddProduct(newProduct));
                Navigator.pop(sheetContext);
              },
            ),
          ),
        );
      },
    );
  }

  // 🔹 BottomSheet para editar producto
  void _showEditProductSheet(BuildContext context, ProductModel product) {

    final bloc = context.read<ProductBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: _ProductForm(
              title: 'Editar producto',
              buttonText: 'Guardar cambios',
              initialName: product.name,
              initialQuantity: product.quantity.toString(),
              initialPrice: product.price.toStringAsFixed(2),
              onSubmit: (name, qty, price) {
                final updated = product.copyWith(
                  name: name,
                  quantity: qty,
                  price: price,
                );
                bloc.add(UpdateProduct(updated));
                Navigator.pop(sheetContext);
              },
            ),
          ),
        );
      },
    );
  }

  // 🔹 BottomSheet para asignar producto a sucursal
  void _showAssignToSubsidiarySheet(
      BuildContext context, ProductModel product) {
    final bloc = context.read<ProductBloc>();
    final controllers = <String, TextEditingController>{};

    for (final sub in _subsidiaries) {
      controllers[sub.subsidiaryId] = TextEditingController();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Asignar cantidades a sucursales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_subsidiaries.isEmpty)
                    const Text(
                      'No hay sucursales disponibles.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Column(
                      children: _subsidiaries.map((subsidiary) {
                        final existingQty = product.subsidiaries
                                .firstWhere(
                                  (ps) =>
                                      ps.subsidiaryId ==
                                      subsidiary.subsidiaryId,
                                  orElse: () => const ProductSubsidiary(
                                      subsidiaryId: '', quantity: 0),
                                )
                                .quantity;
                        controllers[subsidiary.subsidiaryId]!.text =
                            existingQty > 0
                                ? existingQty.toString()
                                : controllers[subsidiary.subsidiaryId]!.text;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(subsidiary.name,
                                      style: const TextStyle(fontSize: 15))),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller:
                                      controllers[subsidiary.subsidiaryId],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Asignar a sucursal'),
                      onPressed: () {
                        final newSubsidiaries = _subsidiaries
                            .map((s) {
                              final qty = int.tryParse(
                                      controllers[s.subsidiaryId]!.text) ??
                                  0;
                              return ProductSubsidiary(
                                subsidiaryId: s.subsidiaryId,
                                quantity: qty,
                              );
                            })
                            .where((ps) => ps.quantity > 0)
                            .toList();

                        final updated =
                            product.copyWith(subsidiaries: newSubsidiaries);
                        bloc.add(UpdateProduct(updated));

                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Asignaciones guardadas correctamente'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🔹 Widget reutilizable para crear/editar producto
class _ProductForm extends StatelessWidget {
  final String title;
  final String buttonText;
  final String? initialName;
  final String? initialQuantity;
  final String? initialPrice;
  final Function(String name, int qty, double price) onSubmit;

  const _ProductForm({
    required this.title,
    required this.buttonText,
    this.initialName,
    this.initialQuantity,
    this.initialPrice,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: initialName ?? '');
    final quantityController =
        TextEditingController(text: initialQuantity ?? '');
    final priceController = TextEditingController(text: initialPrice ?? '');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del producto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad total',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio unitario',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(buttonText),
              onPressed: () {
                final name = nameController.text.trim();
                final qty = int.tryParse(quantityController.text) ?? 0;
                final price = double.tryParse(priceController.text) ?? 0.0;

                if (name.isEmpty || qty <= 0 || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Por favor completa todos los campos correctamente.'),
                    ),
                  );
                  return;
                }

                onSubmit(name, qty, price);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
