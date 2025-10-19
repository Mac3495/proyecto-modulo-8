import 'package:equatable/equatable.dart';
import '../../../data/models/product/product_model.dart';

class ProductState extends Equatable {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ProductState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [products, isLoading, errorMessage];
}
