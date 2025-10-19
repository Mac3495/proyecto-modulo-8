import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_bloc/app_user_cubit.dart';
import '../../../core/routes/routes.dart';
import '../../../data/services/auth/auth_service_impl.dart';
import '../../../data/models/user/user_model.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthServiceImpl _authService;
  final AppUserCubit _appUserCubit;

  SplashCubit(this._appUserCubit)
      : _authService = AuthServiceImpl(),
        super(const SplashState.initial());

  Future<void> checkSession() async {
    emit(const SplashState.loading());
    await Future.delayed(const Duration(seconds: 2)); // simulamos splash

    try {
      final UserModel? user = await _authService.getCurrentUser();

      if (user != null) {
        _appUserCubit.setUser(user);
        final route = user.rol == 'admin'
            ? AppRoutes.adminHome
            : AppRoutes.employeeHome;
        emit(SplashState.navigateTo(route));
      } else {
        emit(SplashState.navigateTo(AppRoutes.signIn));
      }
    } catch (e) {
      emit(SplashState.error(e.toString()));
    }
  }
}
