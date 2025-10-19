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
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final user = await _authService.signIn(state.email, state.password);
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
