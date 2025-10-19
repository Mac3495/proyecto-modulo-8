import 'package:equatable/equatable.dart';
import '../../../data/models/subsidiary/subsidiary_model.dart';

abstract class SubsidiaryEvent extends Equatable {
  const SubsidiaryEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las sucursales
class LoadSubsidiaries extends SubsidiaryEvent {}

/// Crear nueva sucursal
class AddSubsidiary extends SubsidiaryEvent {
  final SubsidiaryModel subsidiary;
  const AddSubsidiary(this.subsidiary);

  @override
  List<Object?> get props => [subsidiary];
}

/// Actualizar sucursal existente
class UpdateSubsidiary extends SubsidiaryEvent {
  final SubsidiaryModel subsidiary;
  const UpdateSubsidiary(this.subsidiary);

  @override
  List<Object?> get props => [subsidiary];
}

/// Eliminar sucursal
class DeleteSubsidiary extends SubsidiaryEvent {
  final String subsidiaryId;
  const DeleteSubsidiary(this.subsidiaryId);

  @override
  List<Object?> get props => [subsidiaryId];
}

/// 🔹 Evento interno para reflejar actualizaciones en tiempo real
class SubsidiariesUpdated extends SubsidiaryEvent {
  final List<SubsidiaryModel> subsidiaries;
  const SubsidiariesUpdated(this.subsidiaries);

  @override
  List<Object?> get props => [subsidiaries];
}
