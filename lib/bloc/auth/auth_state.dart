import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class AuthInitial extends AuthState {}

/// Loading State
class AuthLoading extends AuthState {}

/// Login/Signup Success
class AuthAuthenticated extends AuthState {}

/// User Logged Out
class AuthUnauthenticated extends AuthState {}

/// Error State
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}