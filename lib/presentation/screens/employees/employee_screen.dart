import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_modulo/core/utils/password_generator.dart';
import '../../../data/models/user/user_model.dart';
import '../../modules/employees/employee_bloc.dart';
import '../../modules/employees/employee_event.dart';
import '../../modules/employees/employee_state.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmployeeBloc()..add(LoadEmployees()),
      child: const _EmployeeView(),
    );
  }
}

class _EmployeeView extends StatelessWidget {
  const _EmployeeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Empleados')),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state.isLoading && state.employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage!}'));
          }

          if (state.employees.isEmpty) {
            return const Center(child: Text('No hay empleados registrados.'));
          }

          return ListView.builder(
            itemCount: state.employees.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final emp = state.employees[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(emp.name),
                  subtitle: Text(emp.email),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEmployeeSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEmployeeSheet(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final bloc = context.read<EmployeeBloc>();

    nameController.addListener(() {
      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        passwordController.text = generateSecurePassword(name);
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc, // ✅ reutilizamos el mismo bloc
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Agregar nuevo empleado',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña por defecto',
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
                                  : const Icon(Icons.person_add_alt_1),
                          label: Text(state.isLoading ? 'Agregando...' : 'Agregar empleado'),
                          onPressed:
                              state.isLoading
                                  ? null
                                  : () {
                                    final name = nameController.text.trim();
                                    final email = emailController.text.trim();
                                    final password = passwordController.text.trim();

                                    if (!validatePasswordPolicy(password)) {
                                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'La contraseña no cumple con los requisitos de seguridad.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                                        const SnackBar(
                                          content: Text('Por favor completa todos los campos.'),
                                        ),
                                      );
                                      return;
                                    }

                                    final employee = UserModel(
                                      userId: '', // se asigna en el servicio
                                      email: email,
                                      name: name,
                                      rol: 'employee',
                                      subsidiaryId: null,
                                    );

                                    context.read<EmployeeBloc>().add(
                                      AddEmployee(employee, password),
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

  bool validatePasswordPolicy(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    final minLength = password.length >= 10;

    return hasUpper && hasNumber && hasSpecial && minLength;
  }
}
