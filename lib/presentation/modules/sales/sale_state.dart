import 'package:equatable/equatable.dart';
import '../../../data/models/sale/sale_model.dart';

class SaleState extends Equatable {
  final List<SaleModel> sales;
  final bool isLoading;
  final String? errorMessage;

  const SaleState({
    required this.sales,
    required this.isLoading,
    this.errorMessage,
  });

  const SaleState.initial()
      : sales = const [],
        isLoading = false,
        errorMessage = null;

  SaleState copyWith({
    List<SaleModel>? sales,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SaleState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [sales, isLoading, errorMessage];
}
