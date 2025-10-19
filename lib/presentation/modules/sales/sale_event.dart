import 'package:equatable/equatable.dart';
import '../../../data/models/sale/sale_model.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Cargar todas las ventas (escucha en tiempo real)
class LoadSales extends SaleEvent {}

/// 🔹 Cargar ventas filtradas por sucursal
class LoadSalesBySubsidiary extends SaleEvent {
  final String subsidiaryId;
  const LoadSalesBySubsidiary(this.subsidiaryId);

  @override
  List<Object?> get props => [subsidiaryId];
}

/// 🔹 Agregar una nueva venta
class AddSale extends SaleEvent {
  final SaleModel sale;
  const AddSale(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// 🔹 Eliminar una venta
class DeleteSale extends SaleEvent {
  final String saleId;
  const DeleteSale(this.saleId);

  @override
  List<Object?> get props => [saleId];
}
