import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {

    on<LoginRequested>(_onLoginRequested);

    on<SignupRequested>(_onSignupRequested);

    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {

    emit(AuthLoading());

    try {
      await repository.login(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated());

    } on FirebaseAuthException catch (e) {

      emit(AuthError(e.message ?? "Login Failed"));

    } catch (_) {

      emit(const AuthError("Something went wrong"));

    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {

    emit(AuthLoading());

    try {

      await repository.signup(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated());

    } on FirebaseAuthException catch (e) {

      emit(AuthError(e.message ?? "Signup Failed"));

    } catch (_) {

      emit(const AuthError("Something went wrong"));

    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {

    await repository.logout();

    emit(AuthUnauthenticated());
  }
}