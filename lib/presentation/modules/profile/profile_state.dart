part of 'profile_cubit.dart';

class ProfileState {
  final bool isLoading;
  final bool isLoggedOut;
  final String? errorMessage;

  const ProfileState({
    required this.isLoading,
    required this.isLoggedOut,
    this.errorMessage,
  });

  const ProfileState.initial()
      : isLoading = false,
        isLoggedOut = false,
        errorMessage = null;

  const ProfileState.loggedOut()
      : isLoading = false,
        isLoggedOut = true,
        errorMessage = null;

  ProfileState copyWith({
    bool? isLoading,
    bool? isLoggedOut,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      errorMessage: errorMessage,
    );
  }
}
