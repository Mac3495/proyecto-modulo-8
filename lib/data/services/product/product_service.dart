import '../../models/product/product_model.dart';

abstract class ProductService {
  /// Crear un nuevo producto
  Future<void> createProduct(ProductModel product);

  /// Obtener todos los productos
  Future<List<ProductModel>> getAllProducts();

  /// Actualizar un producto existente
  Future<void> updateProduct(ProductModel product);

  /// Eliminar un producto
  Future<void> deleteProduct(String productId);

  /// Obtener un producto por ID
  Future<ProductModel?> getProductById(String productId);
}
