import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_model.dart';
import 'auth_service.dart';

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('user').doc(uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
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
