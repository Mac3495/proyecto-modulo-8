import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product/product_model.dart';
import 'product_service.dart';

class ProductServiceImpl implements ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'product';

  @override
  Future<void> createProduct(ProductModel product) async {
    try {
      final docRef = _firestore.collection(_collection).doc();

      final newProduct = product.copyWith(productId: docRef.id);
      await docRef.set(newProduct.toMap());
    } catch (e) {
      throw Exception('Error al crear el producto: $e');
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener los productos: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.productId)
          .update(product.toMap());
    } catch (e) {
      throw Exception('Error al actualizar el producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(productId).get();

      if (!doc.exists) return null;
      return ProductModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Error al obtener el producto: $e');
    }
  }
}
