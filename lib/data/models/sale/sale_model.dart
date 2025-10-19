import 'package:equatable/equatable.dart';
import 'sale_product_model.dart';

class SaleModel extends Equatable {
  final String saleId;
  final String subsidiaryId;
  final List<SaleProduct> products;
  final DateTime date;
  final String clientCode;

  const SaleModel({
    required this.saleId,
    required this.subsidiaryId,
    required this.products,
    required this.date,
    required this.clientCode,
  });

  double get totalAmount =>
      products.fold(0, (sum, item) => sum + item.total);

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      saleId: map['saleId'] ?? '',
      subsidiaryId: map['subsidiaryId'] ?? '',
      products: (map['products'] as List<dynamic>?)
              ?.map((p) => SaleProduct.fromMap(Map<String, dynamic>.from(p)))
              .toList() ??
          [],
      date: (map['date'] is DateTime)
          ? map['date']
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      clientCode: map['clientCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'subsidiaryId': subsidiaryId,
      'products': products.map((p) => p.toMap()).toList(),
      'date': date.toIso8601String(),
      'clientCode': clientCode,
    };
  }

  SaleModel copyWith({
    String? saleId,
    String? subsidiaryId,
    List<SaleProduct>? products,
    DateTime? date,
    String? clientCode,
  }) {
    return SaleModel(
      saleId: saleId ?? this.saleId,
      subsidiaryId: subsidiaryId ?? this.subsidiaryId,
      products: products ?? this.products,
      date: date ?? this.date,
      clientCode: clientCode ?? this.clientCode,
    );
  }

  @override
  List<Object?> get props => [saleId, subsidiaryId, products, date, clientCode];
}
