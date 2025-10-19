import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/employee/employee_service.dart';
import '../../../data/services/employee/employee_service_impl.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeService _employeeService;

  EmployeeBloc({EmployeeService? employeeService})
      : _employeeService = employeeService ?? EmployeeServiceImpl(),
        super(const EmployeeState.initial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
      LoadEmployees event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final employees = await _employeeService.getAllEmployees();
      emit(state.copyWith(isLoading: false, employees: employees));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddEmployee(
      AddEmployee event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _employeeService.createEmployee(event.employee, event.password);
      final updated = await _employeeService.getAllEmployees();
      emit(state.copyWith(isLoading: false, employees: updated));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateEmployee(
      UpdateEmployee event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _employeeService.updateEmployee(event.employee);
      final updated = await _employeeService.getAllEmployees();
      emit(state.copyWith(isLoading: false, employees: updated));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(
      DeleteEmployee event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _employeeService.deleteEmployee(event.userId);
      final updated = await _employeeService.getAllEmployees();
      emit(state.copyWith(isLoading: false, employees: updated));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
