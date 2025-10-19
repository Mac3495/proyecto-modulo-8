import '../../models/sale/sale_model.dart';

abstract class SaleService {
  /// Crear una nueva venta
  Future<void> createSale(SaleModel sale);

  /// Obtener todas las ventas
  Future<List<SaleModel>> getAllSales();

  /// Obtener todas las ventas de una sucursal específica
  Future<List<SaleModel>> getSalesBySubsidiary(String subsidiaryId);

  /// Eliminar una venta
  Future<void> deleteSale(String saleId);

  /// 🔹 Stream de ventas en tiempo real (global)
  Stream<List<SaleModel>> streamSales();

  /// 🔹 Stream de ventas en tiempo real por sucursal
  Stream<List<SaleModel>> streamSalesBySubsidiary(String subsidiaryId);
}
