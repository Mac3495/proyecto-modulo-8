import 'package:equatable/equatable.dart';

class SaleProduct extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  const SaleProduct({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  factory SaleProduct.fromMap(Map<String, dynamic> map) {
    return SaleProduct(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [productId, name, quantity, price];
}
