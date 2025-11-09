import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../models/user/user_model.dart';
import 'auth_service.dart';

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lockUntil = {};

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Normalizamos el email (en minúsculas)
      final normalizedEmail = email.trim().toLowerCase();

      // Verificamos si el usuario está temporalmente bloqueado
      if (_lockUntil.containsKey(normalizedEmail)) {
        final lockTime = _lockUntil[normalizedEmail]!;
        if (DateTime.now().isBefore(lockTime)) {
          final remaining = lockTime.difference(DateTime.now()).inSeconds;
          FirebaseCrashlytics.instance.recordError('Error al iniciar sesión.', StackTrace.current);
          throw Exception('Demasiados intentos fallidos. Intenta nuevamente en ${remaining}s.');
        } else {
          // Si ya pasó el tiempo de bloqueo, se reinician los contadores
          _failedAttempts[normalizedEmail] = 0;
          _lockUntil.remove(normalizedEmail);
        }
      }

      // Intento de autenticación
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      // Si llega aquí, autenticación exitosa → reiniciar contador
      _failedAttempts[normalizedEmail] = 0;

      final uid = credential.user?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('user').doc(uid).get();

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      // Incrementamos contador de fallos
      final normalizedEmail = email.trim().toLowerCase();
      _failedAttempts[normalizedEmail] = (_failedAttempts[normalizedEmail] ?? 0) + 1;

      // Si supera el límite → bloqueo temporal (por ejemplo, 30 segundos)
      if (_failedAttempts[normalizedEmail]! >= 3) {
        _lockUntil[normalizedEmail] = DateTime.now().add(const Duration(seconds: 30));
        FirebaseCrashlytics.instance.recordError('Cuenta temporalmente bloqueada por múltiples intentos fallidos. Intenta en 30 segundos.', StackTrace.current);
        throw Exception(
          'Cuenta temporalmente bloqueada por múltiples intentos fallidos. Intenta en 30 segundos.',
        );
      }

      // Propagamos el error mapeado
      FirebaseCrashlytics.instance.recordError('Error en login', StackTrace.current);
      throw Exception(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('user').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap({...doc.data()!, 'userId': user.uid});
  }

  /// Mapeo de errores más legibles
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      default:
        return 'Error inesperado: ${e.message}';
    }
  }
}
