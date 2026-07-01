import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/api_user_model.dart';
import '../../repository/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

List<ApiUserModel> users = [];
List<ApiUserModel> filteredUsers = [];
List<ApiUserModel> visibleUsers = [];

final int pageSize = 20;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUsers>(_loadUsers);
    on<AddUser>(_addUser);
    on<UpdateUser>(_updateUser);
    on<DeleteUser>(_deleteUser);  
    on<SearchUsers>(_searchUsers);
    on<LoadMoreUsers>(_loadMoreUsers);
  }

  Future<void> _loadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    try {
users = await repository.getUsers();

filteredUsers = List.from(users);

visibleUsers = filteredUsers
    .take(pageSize)
    .toList();

emit(
  UserLoaded(
    List.from(visibleUsers),
  ),
);
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _addUser(
    AddUser event,
    Emitter<UserState> emit,
  ) async {
    await repository.addUser(event.user);
    users.add(event.user);
    filteredUsers = List.from(users);
    emit(UserLoaded(filteredUsers));
  }

  Future<void> _updateUser(
  UpdateUser event,
  Emitter<UserState> emit,
) async {
  await repository.updateUser(event.user);
  final index =
      users.indexWhere((u) => u.id == event.user.id);
  if (index != -1) {
    users[index] = event.user;
  }
  filteredUsers = List.from(users);
  emit(UserLoaded(filteredUsers));
}

Future<void> _deleteUser(
  DeleteUser event,
  Emitter<UserState> emit,
) async {

  await repository.deleteUser(event.id);
  users.removeWhere(
    (u) => u.id == event.id,
  );

  filteredUsers = List.from(users);
  emit(UserLoaded(filteredUsers));
}

Future<void> _searchUsers(
  SearchUsers event,
  Emitter<UserState> emit,
) async {

  if (event.query.isEmpty) {
    emit(UserLoaded(List.from(users)));
    return;
  }

  filteredUsers = users.where((user) {

    return user.name
            .toLowerCase()
            .contains(event.query.toLowerCase()) ||

        user.email
            .toLowerCase()
            .contains(event.query.toLowerCase());

  }).toList();

  emit(
    UserLoaded(
      List.from(filteredUsers),
    ),
  );
}

Future<void> _loadMoreUsers(
  LoadMoreUsers event,
  Emitter<UserState> emit,
) async {

  if (visibleUsers.length >= filteredUsers.length) {
    return;
  }

  final nextUsers = filteredUsers.skip(
    visibleUsers.length,
  ).take(
    pageSize,
  );

  visibleUsers.addAll(nextUsers);

  emit(
    UserLoaded(
      List.from(visibleUsers),
    ),
  );
}

}