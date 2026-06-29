import 'package:equatable/equatable.dart';

import '../../models/api_user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<ApiUserModel> users;

  const UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}