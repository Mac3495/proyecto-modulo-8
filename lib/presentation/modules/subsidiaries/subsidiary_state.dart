import 'package:equatable/equatable.dart';
import '../../../data/models/subsidiary/subsidiary_model.dart';

class SubsidiaryState extends Equatable {
  final bool isLoading;
  final List<SubsidiaryModel> subsidiaries;
  final String? errorMessage;

  const SubsidiaryState({
    required this.isLoading,
    required this.subsidiaries,
    this.errorMessage,
  });

  const SubsidiaryState.initial()
      : isLoading = false,
        subsidiaries = const [],
        errorMessage = null;

  SubsidiaryState copyWith({
    bool? isLoading,
    List<SubsidiaryModel>? subsidiaries,
    String? errorMessage,
  }) {
    return SubsidiaryState(
      isLoading: isLoading ?? this.isLoading,
      subsidiaries: subsidiaries ?? this.subsidiaries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, subsidiaries, errorMessage];
}
