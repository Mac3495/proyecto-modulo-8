import 'package:equatable/equatable.dart';
import '../../../data/models/user/user_model.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final UserModel employee;
  final String password;

  const AddEmployee(this.employee, this.password);

  @override
  List<Object?> get props => [employee, password];
}

class UpdateEmployee extends EmployeeEvent {
  final UserModel employee;

  const UpdateEmployee(this.employee);

  @override
  List<Object?> get props => [employee];
}

class DeleteEmployee extends EmployeeEvent {
  final String userId;

  const DeleteEmployee(this.userId);

  @override
  List<Object?> get props => [userId];
}
