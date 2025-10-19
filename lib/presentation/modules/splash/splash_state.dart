import 'package:equatable/equatable.dart';

class SplashState extends Equatable {
  final bool isLoading;
  final String? nextRoute;
  final String? errorMessage;

  const SplashState({
    required this.isLoading,
    this.nextRoute,
    this.errorMessage,
  });

  const SplashState.initial()
      : isLoading = false,
        nextRoute = null,
        errorMessage = null;

  const SplashState.loading()
      : isLoading = true,
        nextRoute = null,
        errorMessage = null;

  const SplashState.navigateTo(this.nextRoute)
      : isLoading = false,
        errorMessage = null;

  const SplashState.error(this.errorMessage)
      : isLoading = false,
        nextRoute = null;

  @override
  List<Object?> get props => [isLoading, nextRoute, errorMessage];
}
