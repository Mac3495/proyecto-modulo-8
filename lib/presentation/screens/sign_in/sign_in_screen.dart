import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_modulo/presentation/modules/sign_in/sign_in_cubit.dart';
import '../../../../data/services/auth/auth_service_impl.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/app_bloc/app_user_cubit.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignInCubit(AuthServiceImpl()),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: SingleChildScrollView(
                child: BlocConsumer<SignInCubit, SignInState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
                      );
                    } else if (state.user != null) {
                      // ✅ Guardar el usuario globalmente
                      context.read<AppUserCubit>().setUser(state.user!);

                      // ✅ Navegar según rol
                      final role = state.user!.rol;
                      String route = AppRoutes.signIn;
                      if (role == 'admin') {
                        route = AppRoutes.adminHome;
                      } else if (role == 'employee') {
                        route = AppRoutes.employeeHome;
                      }

                      Navigator.of(context).pushReplacementNamed(route);
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<SignInCubit>();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.storefront_rounded, size: 90, color: Colors.green),
                        const SizedBox(height: 40),
                        TextFormField(
                          onChanged: cubit.onEmailChanged,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          onChanged: cubit.onPasswordChanged,
                          obscureText: !state.isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: cubit.togglePasswordVisibility,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                state.isLoading || state.isLocked ? null : () => cubit.signIn(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isLocked ? Colors.grey : Colors.green,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              child:
                                  state.isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                        state.isLocked
                                            ? 'Bloqueado (${state.lockEndTime != null ? state.lockEndTime!.difference(DateTime.now()).inSeconds.clamp(0, 30) : 0}s)'
                                            : 'Iniciar sesión',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
