import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/auth/auth_service.dart';
import '../../../data/services/auth/auth_service_impl.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthService _authService;

  ProfileCubit({AuthService? authService})
      : _authService = authService ?? AuthServiceImpl(),
        super(const ProfileState.initial());

  Future<void> logout() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authService.signOut();
      emit(const ProfileState.loggedOut());
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
