part of 'sign_in_cubit.dart';

class SignInState extends Equatable {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;
  final UserModel? user;
  final int failedAttempts;
  final bool isLocked;
  final DateTime? lockEndTime;

  const SignInState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.failedAttempts = 0,
    this.isLocked = false,
    this.lockEndTime,
  });

  SignInState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    int? failedAttempts,
    bool? isLocked,
    DateTime? lockEndTime,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      isLocked: isLocked ?? this.isLocked,
      lockEndTime: lockEndTime ?? this.lockEndTime,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isPasswordVisible,
        isLoading,
        errorMessage,
        user,
        failedAttempts,
        isLocked,
        lockEndTime,
      ];
}
