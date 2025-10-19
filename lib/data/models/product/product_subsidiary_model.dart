import 'package:equatable/equatable.dart';

class ProductSubsidiary extends Equatable {
  final String subsidiaryId;
  final int quantity;

  const ProductSubsidiary({
    required this.subsidiaryId,
    required this.quantity,
  });

  factory ProductSubsidiary.fromMap(Map<String, dynamic> map) {
    return ProductSubsidiary(
      subsidiaryId: map['subsidiaryId'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subsidiaryId': subsidiaryId,
      'quantity': quantity,
    };
  }

  ProductSubsidiary copyWith({
    String? subsidiaryId,
    int? quantity,
  }) {
    return ProductSubsidiary(
      subsidiaryId: subsidiaryId ?? this.subsidiaryId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [subsidiaryId, quantity];
}
