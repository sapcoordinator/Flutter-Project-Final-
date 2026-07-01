import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_user_model.dart';

final List<ApiUserModel> users = [];
void addUser(ApiUserModel user) {
  users.add(user);
}

void updateUser(ApiUserModel updatedUser) {
  final index = users.indexWhere((u) => u.id == updatedUser.id);

  if (index != -1) {
    users[index] = updatedUser;
  }
}

void deleteUser(int id) {
  users.removeWhere((u) => u.id == id);
}

class UserRepository {
  final String apiUrl =
      "https://fake-json-api.mock.beeceptor.com/users";

  Future<List<ApiUserModel>> getUsers() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

                  users
              ..clear()
              ..addAll(
                jsonData
                    .map((user) => ApiUserModel.fromJson(user))
                    .toList(),
              );

            return users;
    } else {
      throw Exception("Failed to load users");
    }
  }

  Future<List<ApiUserModel>> addUser(ApiUserModel user) async {
  await Future.delayed(const Duration(milliseconds: 500));

  users.add(user);

  return List.from(users);
}

Future<List<ApiUserModel>> updateUser(ApiUserModel user) async {
  await Future.delayed(const Duration(milliseconds: 500));

  final index = users.indexWhere((u) => u.id == user.id);

  if (index != -1) {
    users[index] = user;
  }

  return List.from(users);
}

Future<List<ApiUserModel>> deleteUser(int id) async {
  await Future.delayed(const Duration(milliseconds: 500));

  users.removeWhere((u) => u.id == id);

  return List.from(users);
}
}

//   Future<ApiUserModel> addUser(ApiUserModel user) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     return user;
//   }

//   Future<ApiUserModel> updateUser(ApiUserModel user) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     return user;
//   }

//   Future<void> deleteUser(int id) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//   }