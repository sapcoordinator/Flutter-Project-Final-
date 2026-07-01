import 'package:flutter/material.dart';
import 'package:login_page2/models/api_user_model.dart';
import 'package:login_page2/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';


Future<void> saveUsers(List<ApiUserModel> user) async {
  final prefs = await SharedPreferences.getInstance();

  List<String> userList =
      user.map((user) => jsonEncode(user.toMap())).toList();

  await prefs.setStringList('users', userList);
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

    @override
void initState() {
  super.initState();
}
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

      // FIXED FUNCTION
void signup() {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (nameController.text.trim().isEmpty ||
      email.isEmpty ||
      password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all fields"),
      ),
    );
    return;
  }

  context.read<AuthBloc>().add(
    SignupRequested(
      email: email,
      password: password,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      NotificationService.show(
        "Signup Successful",
        "Account created",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signup Successful"),
        ),
      );

      Navigator.pop(context);
    }

    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );
    }
  },
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      return Scaffold(
      appBar: AppBar(title: Text("Create your wise Account", 
      style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
       backgroundColor:  Color.fromARGB(255, 80, 58, 161),
       ),

      body: Stack(
       children: [
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Color.fromARGB(255, 209, 191, 220),  Color.fromARGB(255, 247, 247, 247)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
  ),
  // borderRadius: BorderRadius.circular(10),
), 

      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),          
            child: Center(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              
            children: [
                SizedBox(height: 40), //  ADDED (push card to center)
                // Padding( padding: EdgeInsets.only(left: 50),
                SizedBox( width: 420,   //SET WIDTH
                                 height: 460,
              
              child: Card(   // ADDED (main design)
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                  Text(
                    "Sign Up for Free",   //  ADDED
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),
      
          Padding(
            padding: const EdgeInsets.all(16),
            // child: Center(
            child: Column(
              children: [
                
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name",

                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is AuthLoading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Color.fromARGB(255, 80, 58, 161),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),

                  child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                           ),
                           SizedBox(height: 15),

                                       TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
              child: Text("Already have an Account? \n Go to Login.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
                  ),
                )
                      
                    ],
                  ),
                ),
              ]
            )
          )
        )
      )
            ]
            )
        )
      )
      )
      )
       ]
      )

    //     Positioned(
    //   bottom: 5,
    //   right: 0,
    //   child: Image.asset(
    //     'assets/login2.png', //your add here image
    //     width: 500,
    //     height: 500,
    //     opacity: const AlwaysStoppedAnimation(6), //light effect 
    //   ),
    // ),
    );
    }
    )
    );
  }
}