import 'package:equatable/equatable.dart';
import '../../data/models/user/user_model.dart';

class AppUserState extends Equatable {
  final UserModel? user;
  final bool isAuthenticated;

  const AppUserState({
    required this.user,
    required this.isAuthenticated,
  });

  const AppUserState.initial()
      : user = null,
        isAuthenticated = false;

  const AppUserState.authenticated(UserModel user)
      : user = user,
        isAuthenticated = true;

  const AppUserState.unauthenticated()
      : user = null,
        isAuthenticated = false;

  @override
  List<Object?> get props => [user, isAuthenticated];
}
