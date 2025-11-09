import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/user/user_model.dart';
import '../../../../data/services/auth/auth_service.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final AuthService _authService;

  SignInCubit(this._authService) : super(const SignInState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void onEmailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  Future<void> signIn() async {
    // Bloqueo temporal activo
    if (state.isLocked) {
      final remaining = state.lockEndTime!
          .difference(DateTime.now())
          .inSeconds
          .clamp(0, 30);
      emit(state.copyWith(
        errorMessage:
            'Demasiados intentos fallidos. Intente nuevamente en ${remaining}s.',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final user = await _authService.signIn(state.email, state.password);

      emit(state.copyWith(
        isLoading: false,
        user: user,
        failedAttempts: 0,
        isLocked: false,
        lockEndTime: null,
      ));
    } catch (e) {
      final newAttempts = state.failedAttempts + 1;

      // Si llega a 3 intentos fallidos → bloqueo 30 segundos
      if (newAttempts >= 3) {
        final lockTime = DateTime.now().add(const Duration(seconds: 30));
        emit(state.copyWith(
          isLoading: false,
          failedAttempts: newAttempts,
          isLocked: true,
          lockEndTime: lockTime,
          errorMessage:
              'Cuenta bloqueada temporalmente por múltiples intentos fallidos. Intente en 30 segundos.',
        ));

        // Desbloqueo automático después de 30s
        Future.delayed(const Duration(seconds: 30), () {
          emit(state.copyWith(
            failedAttempts: 0,
            isLocked: false,
            lockEndTime: null,
            errorMessage: null,
          ));
        });
      } else {
        emit(state.copyWith(
          isLoading: false,
          failedAttempts: newAttempts,
          errorMessage:
              'Credenciales incorrectas. Intento $newAttempts de 3.',
        ));
      }
    }
  }
}
