import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_modulo/data/models/subsidiary/subsidiary_model.dart';
import '../../../data/services/subsidiary/subsidiary_service.dart';
import '../../../data/services/subsidiary/subsidiary_service_impl.dart';
import 'subsidiary_event.dart';
import 'subsidiary_state.dart';

class SubsidiaryBloc extends Bloc<SubsidiaryEvent, SubsidiaryState> {
  final SubsidiaryService _subsidiaryService;
  StreamSubscription<List<SubsidiaryModel>>? _subsidiarySubscription;

  SubsidiaryBloc({SubsidiaryService? subsidiaryService})
      : _subsidiaryService = subsidiaryService ?? SubsidiaryServiceImpl(),
        super(const SubsidiaryState.initial()) {
    on<LoadSubsidiaries>(_onLoadSubsidiaries);
    on<AddSubsidiary>(_onAddSubsidiary);
    on<UpdateSubsidiary>(_onUpdateSubsidiary);
    on<DeleteSubsidiary>(_onDeleteSubsidiary);
    on<SubsidiariesUpdated>(_onSubsidiariesUpdated);
  }

  /// Escuchar la colección en tiempo real
  Future<void> _onLoadSubsidiaries(
      LoadSubsidiaries event, Emitter<SubsidiaryState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    await _subsidiarySubscription?.cancel(); // cancelar si ya había un stream activo
    _subsidiarySubscription = _subsidiaryService.streamSubsidiaries().listen(
      (subsidiaries) {
        add(SubsidiariesUpdated(subsidiaries));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  /// Cuando llegan nuevas sucursales del stream
  void _onSubsidiariesUpdated(
      SubsidiariesUpdated event, Emitter<SubsidiaryState> emit) {
    emit(state.copyWith(isLoading: false, subsidiaries: event.subsidiaries));
  }

  /// Crear nueva sucursal
  Future<void> _onAddSubsidiary(
      AddSubsidiary event, Emitter<SubsidiaryState> emit) async {
    try {
      await _subsidiaryService.createSubsidiary(event.subsidiary);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Actualizar sucursal
  Future<void> _onUpdateSubsidiary(
      UpdateSubsidiary event, Emitter<SubsidiaryState> emit) async {
    try {
      await _subsidiaryService.updateSubsidiary(event.subsidiary);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Eliminar sucursal
  Future<void> _onDeleteSubsidiary(
      DeleteSubsidiary event, Emitter<SubsidiaryState> emit) async {
    try {
      await _subsidiaryService.deleteSubsidiary(event.subsidiaryId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subsidiarySubscription?.cancel();
    return super.close();
  }
}