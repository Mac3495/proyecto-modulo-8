import 'package:equatable/equatable.dart';
import '../../../data/models/user/user_model.dart';

class EmployeeState extends Equatable {
  final bool isLoading;
  final List<UserModel> employees;
  final String? errorMessage;

  const EmployeeState({
    required this.isLoading,
    required this.employees,
    this.errorMessage,
  });

  const EmployeeState.initial()
      : isLoading = false,
        employees = const [],
        errorMessage = null;

  EmployeeState copyWith({
    bool? isLoading,
    List<UserModel>? employees,
    String? errorMessage,
  }) {
    return EmployeeState(
      isLoading: isLoading ?? this.isLoading,
      employees: employees ?? this.employees,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, employees, errorMessage];
}
