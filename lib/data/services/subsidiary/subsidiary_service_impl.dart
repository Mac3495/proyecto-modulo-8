import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/subsidiary/subsidiary_model.dart';
import 'subsidiary_service.dart';

class SubsidiaryServiceImpl implements SubsidiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'subsidiary';

  @override
  Future<void> createSubsidiary(SubsidiaryModel subsidiary) async {
    try {
      // Generamos ID automático si no existe
      final docRef = _firestore.collection(_collection).doc();
      final newSubsidiary = subsidiary.copyWith(subsidiaryId: docRef.id);

      await docRef.set(newSubsidiary.toMap());
    } catch (e) {
      throw Exception('Error al crear la sucursal: $e');
    }
  }

  @override
  Future<List<SubsidiaryModel>> getAllSubsidiaries() async {
    try {
      final query = await _firestore.collection(_collection).get();
      return query.docs
          .map((doc) => SubsidiaryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener sucursales: $e');
    }
  }

  @override
  Future<SubsidiaryModel?> getSubsidiaryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return SubsidiaryModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Error al obtener sucursal: $e');
    }
  }

  @override
  Future<void> updateSubsidiary(SubsidiaryModel subsidiary) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(subsidiary.subsidiaryId)
          .update(subsidiary.toMap());
    } catch (e) {
      throw Exception('Error al actualizar sucursal: $e');
    }
  }

  @override
  Future<void> deleteSubsidiary(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar sucursal: $e');
    }
  }

   /// 🔹 Nueva: flujo en tiempo real
  @override
  Stream<List<SubsidiaryModel>> streamSubsidiaries() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SubsidiaryModel.fromMap(doc.data()).copyWith(subsidiaryId: doc.id))
          .toList();
    });
  }
}
