import 'package:equatable/equatable.dart';
import '../../models/api_user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {
  const LoadUsers();
}

class SearchUsers extends UserEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class AddUser extends UserEvent {
  final ApiUserModel user;

  const AddUser(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUser extends UserEvent {
  final ApiUserModel user;

  const UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}

class DeleteUser extends UserEvent {
  final int id;

  const DeleteUser(this.id);

  @override
  List<Object?> get props => [id];
}


class LoadMoreUsers extends UserEvent {
  const LoadMoreUsers();
}

// class AddUser extends UserEvent { 
//   final ApiUserModel user;

//   const AddUser(this.user);

//   @override
//   List<Object?> get props => [user];
// }

// class UpdateUser extends UserEvent {
//   final ApiUserModel user;

//   const UpdateUser(this.user);

//   @override
//   List<Object?> get props => [user];
// }

// class DeleteUser extends UserEvent {
//   final int id;

//   const DeleteUser(this.id);

//   @override
//   List<Object?> get props => [id];
// }