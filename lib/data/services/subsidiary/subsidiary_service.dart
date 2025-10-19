import '../../models/subsidiary/subsidiary_model.dart';

abstract class SubsidiaryService {
  /// Crear una nueva sucursal
  Future<void> createSubsidiary(SubsidiaryModel subsidiary);

  /// Obtener todas las sucursales
  Future<List<SubsidiaryModel>> getAllSubsidiaries();

  /// Obtener una sucursal por ID
  Future<SubsidiaryModel?> getSubsidiaryById(String id);

  /// Actualizar una sucursal existente
  Future<void> updateSubsidiary(SubsidiaryModel subsidiary);

  /// Eliminar una sucursal
  Future<void> deleteSubsidiary(String id);

  Stream<List<SubsidiaryModel>> streamSubsidiaries();
}
