import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user/user_model.dart';
import 'employee_service.dart';

class EmployeeServiceImpl implements EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String _collection = 'user';

  @override
  Future<void> createEmployee(UserModel employee, String password) async {
    try {
      final currentAdmin = _auth.currentUser;
      final currentAdminEmail = currentAdmin?.email;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: employee.email,
        password: password,
      );

      final String uid = credential.user!.uid;
      final newEmployee = employee.copyWith(userId: uid, rol: 'employee');
      await _firestore.collection(_collection).doc(uid).set(newEmployee.toMap());
      await _auth.signOut();

      if (currentAdminEmail != null) {
        await _auth.signInWithEmailAndPassword(
          email: currentAdminEmail,
          password: 'tienda123',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      throw Exception('Error al crear empleado: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllEmployees() async {
    try {
      final query =
          await _firestore.collection(_collection).where('rol', isEqualTo: 'employee').get();

      return query.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Error al obtener empleados: $e');
    }
  }

  @override
  Future<UserModel?> getEmployeeById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Error al obtener empleado: $e');
    }
  }

  @override
  Future<void> updateEmployee(UserModel employee) async {
    try {
      await _firestore.collection(_collection).doc(employee.userId).update(employee.toMap());
    } catch (e) {
      throw Exception('Error al actualizar empleado: $e');
    }
  }

  @override
  Future<void> deleteEmployee(String userId) async {
    try {
      // 🔹 Eliminar de Firestore
      await _firestore.collection(_collection).doc(userId).delete();

      // 🔹 Eliminar también del Auth (si es necesario)
      final userRecord = await _auth.currentUser;
      if (userRecord != null) {
        await _auth.currentUser?.delete();
      }
    } catch (e) {
      throw Exception('Error al eliminar empleado: $e');
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está en uso.';
      case 'invalid-email':
        return 'Correo electrónico inválido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      default:
        return 'Error inesperado: ${e.message}';
    }
  }
}
