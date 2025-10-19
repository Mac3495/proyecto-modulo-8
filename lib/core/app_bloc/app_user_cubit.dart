import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_user_state.dart';
import '../../data/models/user/user_model.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(const AppUserState.initial());

  void setUser(UserModel user) {
    emit(AppUserState.authenticated(user));
  }

  void clearUser() {
    emit(const AppUserState.unauthenticated());
  }
}
