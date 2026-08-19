part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSessionRestoring extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phone;
  final String? devOtp;
  final bool isResend;

  const AuthOtpSent({required this.phone, this.devOtp, this.isResend = false});

  @override
  List<Object?> get props => [phone, devOtp, isResend];
}

class AuthAuthenticated extends AuthState {
  final OwnerEntity owner;
  final bool isNewUser;

  const AuthAuthenticated({required this.owner, this.isNewUser = false});

  bool get requiresRegistration => isNewUser || !owner.isProfileComplete;

  @override
  List<Object?> get props => [owner.id, isNewUser, owner.isProfileComplete];
}

class AuthProfileCompleted extends AuthAuthenticated {
  const AuthProfileCompleted({required super.owner});
}

class AuthUnauthenticated extends AuthState {}

class AuthSessionRestoreError extends AuthState {
  final String message;

  const AuthSessionRestoreError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthGoogleNeedsPhone extends AuthState {
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  const AuthGoogleNeedsPhone({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  @override
  List<Object?> get props => [email, firstName, lastName, avatar];
}

class AuthAccountDeletedWithin30Days extends AuthState {
  final String name;
  final String deletionDate;
  final String restoreUntilDate;
  final String phone;

  const AuthAccountDeletedWithin30Days({
    required this.name,
    required this.deletionDate,
    required this.restoreUntilDate,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, deletionDate, restoreUntilDate, phone];
}

class AuthAccountDeletedPast30Days extends AuthState {
  final String phone;

  const AuthAccountDeletedPast30Days({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class AuthAccountRestored extends AuthState {}
