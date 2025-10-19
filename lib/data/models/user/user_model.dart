import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String userId;        // 🔹 UID de Firebase
  final String email;
  final String name;
  final String rol;           // 'admin' o 'employee'
  final String? subsidiaryId; // puede ser null si es admin

  const UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.rol,
    this.subsidiaryId,
  });

  /// Crear una instancia desde Firebase o JSON
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      rol: map['rol'] ?? '',
      subsidiaryId: map['subsidiaryId'],
    );
  }

  /// Convertir el modelo a Map (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'rol': rol,
      'subsidiaryId': subsidiaryId,
    };
  }

  /// Copia modificable
  UserModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? rol,
    String? subsidiaryId,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      rol: rol ?? this.rol,
      subsidiaryId: subsidiaryId ?? this.subsidiaryId,
    );
  }

  @override
  List<Object?> get props => [userId, email, name, rol, subsidiaryId];
}
