import '../../models/user/user_model.dart';

abstract class EmployeeService {
  /// Crear un nuevo empleado
  Future<void> createEmployee(UserModel employee, String password);

  /// Obtener todos los empleados
  Future<List<UserModel>> getAllEmployees();

  /// Obtener un empleado por ID
  Future<UserModel?> getEmployeeById(String userId);

  /// Actualizar datos del empleado
  Future<void> updateEmployee(UserModel employee);

  /// Eliminar empleado (Auth + Firestore)
  Future<void> deleteEmployee(String userId);
}
