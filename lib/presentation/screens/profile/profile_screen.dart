import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_bloc/app_user_cubit.dart';
import '../../../core/routes/routes.dart';
import '../../modules/profile/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUserCubit>().state.user;

    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.isLoggedOut) {
            // 🔹 Limpia el usuario global y redirige
            context.read<AppUserCubit>().clearUser();
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.signIn, (_) => false);
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null) ...[
                    Text(
                      user.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(user.email, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Rol: ${user.rol}'),
                    if (user.subsidiaryId != null)
                      Text('Sucursal: ${user.subsidiaryId}'),
                    const Divider(height: 40),
                  ],
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: state.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed:
                          state.isLoading ? null : () => cubit.logout(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
