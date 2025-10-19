import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_modulo/presentation/modules/splash/splash_cubit.dart';
import 'package:proyecto_modulo/presentation/modules/splash/splash_state.dart';
import '../../../../core/app_bloc/app_user_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(context.read<AppUserCubit>())..checkSession(),
      child: BlocListener<SplashCubit, SplashState>(
        listenWhen: (p, c) => c.nextRoute != null,
        listener: (context, state) {
          Navigator.pushReplacementNamed(context, state.nextRoute!);
        },
        child: Scaffold(
          body: Center(
            child: BlocBuilder<SplashCubit, SplashState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Text(
                    'App Inventario',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  );
                }

                if (state.errorMessage != null) {
                  return Text(
                    'Error: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                return const Text(
                  'App Inventario',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
