import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/subsidiary/subsidiary_model.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/services/employee/employee_service_impl.dart';
import '../../modules/subsidiaries/subsidiary_bloc.dart';
import '../../modules/subsidiaries/subsidiary_event.dart';
import '../../modules/subsidiaries/subsidiary_state.dart';

class SubsidiaryScreen extends StatefulWidget {
  const SubsidiaryScreen({super.key});

  @override
  State<SubsidiaryScreen> createState() => _SubsidiaryScreenState();
}

class _SubsidiaryScreenState extends State<SubsidiaryScreen> {
  final _employeeService = EmployeeServiceImpl();
  List<UserModel> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final employees = await _employeeService.getAllEmployees();
    setState(() {
      _employees = employees;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubsidiaryBloc()..add(LoadSubsidiaries()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gestión de Sucursales')),
        body: BlocBuilder<SubsidiaryBloc, SubsidiaryState>(
          builder: (context, state) {
            if (state.isLoading && state.subsidiaries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(
                child: Text(
                  'Error: ${state.errorMessage!}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state.subsidiaries.isEmpty) {
              return const Center(child: Text('No hay sucursales registradas.'));
            }

            return ListView.builder(
              itemCount: state.subsidiaries.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final sub = state.subsidiaries[index];

                // 🔹 Buscar encargado asignado
                final encargado = _employees.firstWhere(
                  (emp) => emp.userId == sub.employeeId,
                  orElse:
                      () => const UserModel(
                        userId: '',
                        email: '',
                        name: 'Sin encargado asignado',
                        rol: 'employee',
                        subsidiaryId: null,
                      ),
                );

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    sub.isOpen ? Icons.circle : Icons.circle_outlined,
                                    size: 12,
                                    color: sub.isOpen ? Colors.green : Colors.redAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sub.isOpen ? 'Abierta' : 'Cerrada',
                                    style: TextStyle(
                                      color: sub.isOpen ? Colors.green : Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Encargado: ${encargado.name}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: encargado.userId.isEmpty ? Colors.grey : Colors.black87,
                                  fontStyle:
                                      encargado.userId.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Switch(
                              value: sub.isOpen,
                              onChanged: (value) {
                                final updated = sub.copyWith(isOpen: value);
                                context.read<SubsidiaryBloc>().add(UpdateSubsidiary(updated));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar encargado',
                              onPressed: () => _showAssignEmployeeSheet(context, sub),
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
          onPressed: () => _showAddSubsidiarySheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddSubsidiarySheet(BuildContext context) {
    final nameController = TextEditingController();
    final bloc = context.read<SubsidiaryBloc>(); // obtenemos el bloc activo

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // 🔹 reusamos el mismo bloc dentro del modal
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: BlocBuilder<SubsidiaryBloc, SubsidiaryState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Agregar nueva sucursal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la sucursal',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon:
                              state.isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.store),
                          label: Text(state.isLoading ? 'Agregando...' : 'Agregar sucursal'),
                          onPressed:
                              state.isLoading
                                  ? null
                                  : () {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Por favor ingresa el nombre de la sucursal.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final newSubsidiary = SubsidiaryModel(
                                      subsidiaryId: '',
                                      name: name,
                                      isOpen: true,
                                      employeeId: null,
                                    );

                                    // ✅ usamos el mismo bloc que ya existe
                                    context.read<SubsidiaryBloc>().add(
                                      AddSubsidiary(newSubsidiary),
                                    );

                                    Navigator.pop(sheetContext);
                                  },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAssignEmployeeSheet(BuildContext context, SubsidiaryModel subsidiary) async {
    final bloc = context.read<SubsidiaryBloc>();
    final employees = _employees; // usamos la lista ya cargada

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Asignar empleado a la sucursal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                if (employees.isEmpty) const Text('No hay empleados disponibles.'),
                if (employees.isNotEmpty)
                  ...employees.map((emp) {
                    final isSelected = emp.userId == subsidiary.employeeId;
                    return ListTile(
                      title: Text(emp.name),
                      subtitle: Text(emp.email),
                      trailing:
                          isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                      onTap: () {
                        final updated = subsidiary.copyWith(employeeId: emp.userId);
                        context.read<SubsidiaryBloc>().add(UpdateSubsidiary(updated));
                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Encargado asignado: ${emp.name} a ${subsidiary.name}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green.shade600,
                          ),
                        );
                      },
                    );
                  }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
