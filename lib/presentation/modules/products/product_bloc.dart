import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../../../data/services/product/product_service_impl.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductServiceImpl _productService = ProductServiceImpl();

  ProductBloc() : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final products = await _productService.getAllProducts();
      emit(state.copyWith(isLoading: false, products: products));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _productService.createProduct(event.product);
      final products = await _productService.getAllProducts();
      emit(state.copyWith(isLoading: false, products: products));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _productService.updateProduct(event.product);
      final products = await _productService.getAllProducts();
      emit(state.copyWith(isLoading: false, products: products));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _productService.deleteProduct(event.productId);
      final products = await _productService.getAllProducts();
      emit(state.copyWith(isLoading: false, products: products));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
