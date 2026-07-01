import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'package:flutter/material.dart';
import 'repository/auth_repository.dart';
import 'package:login_page2/bloc/auth/auth_bloc.dart';


import 'package:flutter_bloc/flutter_bloc.dart';

import 'pages/login_page.dart';

import 'bloc/user/user_bloc.dart';
import 'repository/user_repository.dart';

//LOAD USERS FROM STORAGE
// Future<List<ApiUserModel>> loadUsers() async {
//   final prefs = await SharedPreferences.getInstance();

//   List<String>? userList = prefs.getStringList('users');

//   if (userList == null) return [];

// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
    await Firebase.initializeApp();
    await NotificationService.init(); //IMPORTANT//LOAD SAVED DATA

  runApp(
  MultiBlocProvider(
    providers: [

      BlocProvider<UserBloc>(
        create: (_) => UserBloc(UserRepository()),
      ),

      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(AuthRepository()),
      ),

    ],
    child: const MyApp(),
  ),
);
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