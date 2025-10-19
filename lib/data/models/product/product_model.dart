import 'package:equatable/equatable.dart';
import 'product_subsidiary_model.dart';

class ProductModel extends Equatable {
  final String productId;
  final String name;
  final int quantity; // cantidad total
  final double price;
  final List<ProductSubsidiary> subsidiaries; // distribución por sucursal

  const ProductModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.subsidiaries,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
      subsidiaries: (map['subsidiaries'] != null)
          ? List<Map<String, dynamic>>.from(map['subsidiaries'])
              .map((e) => ProductSubsidiary.fromMap(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'subsidiaries':
          subsidiaries.map((s) => s.toMap()).toList(), // lista de maps
    };
  }

  ProductModel copyWith({
    String? productId,
    String? name,
    int? quantity,
    double? price,
    List<ProductSubsidiary>? subsidiaries,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subsidiaries: subsidiaries ?? this.subsidiaries,
    );
  }

  @override
  List<Object?> get props => [productId, name, quantity, price, subsidiaries];
}
