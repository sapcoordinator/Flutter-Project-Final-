import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUsers>(_loadUsers);
  }

  Future<void> _loadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    try {
      final users = await repository.getUsers();

      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}