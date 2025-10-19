import '../../models/user/user_model.dart';

abstract class AuthService {
  /// Inicia sesión con email y contraseña
  Future<UserModel?> signIn(String email, String password);

  /// Cierra la sesión actual
  Future<void> signOut();

  /// Obtiene el usuario actualmente autenticado (si existe)
  Future<UserModel?> getCurrentUser();
}
