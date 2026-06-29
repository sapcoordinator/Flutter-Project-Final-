import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_user_model.dart';

class UserRepository {
  final String apiUrl =
      "https://fake-json-api.mock.beeceptor.com/users"; //https://fake-json-api.mock.beeceptor.com/users

  Future<List<ApiUserModel>> getUsers() async {
    final response = await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          jsonDecode(response.body);

      return jsonData
          .map((user) => ApiUserModel.fromJson(user))
          .toList();
    } else {
      throw Exception("Failed to load users");
    }
  }
}