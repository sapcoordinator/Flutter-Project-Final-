import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_storage.dart' as storage;
import 'models/user_model.dart';
import 'pages/login_page.dart';

//LOAD USERS FROM STORAGE
Future<List<UserModel>> loadUsers() async {
  final prefs = await SharedPreferences.getInstance();

  List<String>? userList = prefs.getStringList('users');

  if (userList == null) return [];

  return userList
      .map((user) => UserModel.fromMap(jsonDecode(user)))
      .toList();
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
    await Firebase.initializeApp();
    await NotificationService.init(); //IMPORTANT

  storage.users = await loadUsers(); //LOAD SAVED DATA

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LoginPage(),
    );
  }
}