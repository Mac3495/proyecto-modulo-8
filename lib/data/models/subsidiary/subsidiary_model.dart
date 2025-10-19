import 'package:equatable/equatable.dart';

class SubsidiaryModel extends Equatable {
  final String subsidiaryId;
  final String name;
  final bool isOpen;
  final String? employeeId; // puede ser null si aún no hay encargado

  const SubsidiaryModel({
    required this.subsidiaryId,
    required this.name,
    required this.isOpen,
    this.employeeId,
  });

  /// Crear instancia desde Firebase o JSON
  factory SubsidiaryModel.fromMap(Map<String, dynamic> map) {
    return SubsidiaryModel(
      subsidiaryId: map['subsidiaryId'] ?? '',
      name: map['name'] ?? '',
      isOpen: map['isOpen'] ?? false,
      employeeId: map['employeeId'],
    );
  }

  /// Convertir a mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'subsidiaryId': subsidiaryId,
      'name': name,
      'isOpen': isOpen,
      'employeeId': employeeId,
    };
  }

  /// Copia modificable
  SubsidiaryModel copyWith({
    String? subsidiaryId,
    String? name,
    bool? isOpen,
    String? employeeId,
  }) {
    return SubsidiaryModel(
      subsidiaryId: subsidiaryId ?? this.subsidiaryId,
      name: name ?? this.name,
      isOpen: isOpen ?? this.isOpen,
      employeeId: employeeId ?? this.employeeId,
    );
  }

  @override
  List<Object?> get props => [subsidiaryId, name, isOpen, employeeId];
}
