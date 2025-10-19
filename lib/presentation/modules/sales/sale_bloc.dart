import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/sale/sale_model.dart';
import '../../../data/services/sale/sale_service.dart';
import '../../../data/services/sale/sale_service_impl.dart';
import 'sale_event.dart';
import 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleService _saleService;
  StreamSubscription<List<SaleModel>>? _salesSubscription;

  SaleBloc({SaleService? saleService})
      : _saleService = saleService ?? SaleServiceImpl(),
        super(const SaleState.initial()) {
    on<LoadSales>(_onLoadSales);
    on<LoadSalesBySubsidiary>(_onLoadSalesBySubsidiary);
    on<_SalesUpdated>(_onSalesUpdated);
    on<AddSale>(_onAddSale);
    on<DeleteSale>(_onDeleteSale);
  }

  /// 🔹 Escuchar todas las ventas en tiempo real
  Future<void> _onLoadSales(LoadSales event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _salesSubscription?.cancel();
    _salesSubscription = _saleService.streamSales().listen(
      (sales) {
        add(_SalesUpdated(sales));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  /// 🔹 Escuchar ventas por sucursal en tiempo real
  Future<void> _onLoadSalesBySubsidiary(
      LoadSalesBySubsidiary event, Emitter<SaleState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _salesSubscription?.cancel();
    _salesSubscription =
        _saleService.streamSalesBySubsidiary(event.subsidiaryId).listen(
      (sales) {
        add(_SalesUpdated(sales));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  /// 🔹 Cuando hay actualizaciones desde Firestore
  void _onSalesUpdated(_SalesUpdated event, Emitter<SaleState> emit) {
    emit(state.copyWith(isLoading: false, sales: event.sales));
  }

  /// 🔹 Agregar nueva venta
  Future<void> _onAddSale(AddSale event, Emitter<SaleState> emit) async {
    try {
      await _saleService.createSale(event.sale);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// 🔹 Eliminar venta
  Future<void> _onDeleteSale(DeleteSale event, Emitter<SaleState> emit) async {
    try {
      await _saleService.deleteSale(event.saleId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _salesSubscription?.cancel();
    return super.close();
  }
}

/// 🔹 Evento interno para actualizaciones en tiempo real
class _SalesUpdated extends SaleEvent {
  final List<SaleModel> sales;
  const _SalesUpdated(this.sales);

  @override
  List<Object?> get props => [sales];
}
