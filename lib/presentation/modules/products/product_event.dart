import 'package:equatable/equatable.dart';
import '../../../data/models/product/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los productos
class LoadProducts extends ProductEvent {}

/// Crear un nuevo producto
class AddProduct extends ProductEvent {
  final ProductModel product;
  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// Actualizar un producto
class UpdateProduct extends ProductEvent {
  final ProductModel product;
  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// Eliminar un producto
class DeleteProduct extends ProductEvent {
  final String productId;
  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}
