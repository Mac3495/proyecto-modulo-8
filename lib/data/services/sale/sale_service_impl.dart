import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sale/sale_model.dart';
import 'sale_service.dart';

class SaleServiceImpl implements SaleService {
  final _collection = FirebaseFirestore.instance.collection('sales');

  @override
  Future<void> createSale(SaleModel sale) async {
    try {
      final docRef = _collection.doc();
      final newSale = sale.copyWith(saleId: docRef.id);
      await docRef.set(newSale.toMap());
    } catch (e) {
      throw Exception('Error al crear la venta: $e');
    }
  }

  @override
  Future<List<SaleModel>> getAllSales() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs
          .map((doc) =>
              SaleModel.fromMap(doc.data()).copyWith(saleId: doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las ventas: $e');
    }
  }

  @override
  Future<List<SaleModel>> getSalesBySubsidiary(String subsidiaryId) async {
    try {
      final snapshot = await _collection
          .where('subsidiaryId', isEqualTo: subsidiaryId)
          .get();
      return snapshot.docs
          .map((doc) =>
              SaleModel.fromMap(doc.data()).copyWith(saleId: doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las ventas de la sucursal: $e');
    }
  }

  @override
  Future<void> deleteSale(String saleId) async {
    try {
      await _collection.doc(saleId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la venta: $e');
    }
  }

  // 🔹 Stream global en tiempo real (todas las ventas)
  @override
  Stream<List<SaleModel>> streamSales() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SaleModel.fromMap(doc.data()).copyWith(saleId: doc.id))
          .toList();
    });
  }

  // 🔹 Stream en tiempo real por sucursal
  @override
  Stream<List<SaleModel>> streamSalesBySubsidiary(String subsidiaryId) {
    return _collection
        .where('subsidiaryId', isEqualTo: subsidiaryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SaleModel.fromMap(doc.data()).copyWith(saleId: doc.id))
          .toList();
    });
  }
}
