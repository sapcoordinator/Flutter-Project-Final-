import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_page2/bloc/auth/auth_bloc.dart';
import 'package:login_page2/bloc/auth/auth_event.dart';
import 'package:login_page2/pages/signup_page.dart';
import '../services/notification_service.dart';
import 'home_page.dart';
import '../bloc/auth/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  void showForgotPasswordPhoneDialog() {
  TextEditingController phoneInput = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Forgot Password"),
      content: SizedBox(
      width: 400, //increase width here
      child: TextField(
        controller: phoneInput,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: "Enter phone number",
          prefixIcon: Icon(Icons.phone),
        ),
      ),
     ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);

            await FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: phoneInput.text.trim(),

              verificationCompleted: (credential) async {
                await FirebaseAuth.instance.signInWithCredential(credential);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(),
                  ),
                );
              },

              verificationFailed: (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message ?? "Error")),
                );
              },

              codeSent: (verificationId, _) {
                showOtpDialog(verificationId);
              },

              codeAutoRetrievalTimeout: (_) {},
            );
          },
          child: const Text("Send OTP"),
        )
      ],
    ),
  );
}

  // 🔐 EMAIL LOGIN
  void login() {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all fields"),
      ),
    );
    return;
  }

  context.read<AuthBloc>().add(
    LoginRequested(
      email: email,
      password: password,
    ),
  );
}

  // 🔵 GOOGLE LOGIN
Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    if (googleAuth.idToken == null) {
      print("ID Token is null");
      return;
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    NotificationService.show(
      "Google Login",
      "Welcome ${googleUser.displayName}",
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(),
      ),
    );
  } catch (e) {
    print("Google Login Error: $e");
  }
}

  // 📱 PHONE LOGIN
  Future<void> signInWithPhone() async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter phone number")),
      );
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        print(e.message);
      },
      codeSent: (verificationId, resendToken) {
        showOtpDialog(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  void showOtpDialog(String verificationId) {
    TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter OTP"),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              PhoneAuthCredential credential =
                  PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: otpController.text.trim(),
              );

              await FirebaseAuth.instance
                  .signInWithCredential(credential);

              Navigator.pop(context);

              NotificationService.show(
                "Phone Login",
                "Login Successful",
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>const HomePage(),
                ),
              );
            },
            child: const Text("Verify"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {

    if (state is AuthAuthenticated) {

      NotificationService.show(
        "Login Successful",
        "Welcome back 👋",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
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
      body: Stack(
        children: [
          // 🌈 Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ Color.fromARGB(255, 209, 191, 220), 
                          Color.fromARGB(255, 247, 247, 247)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                // color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 24),

                      // EMAIL
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),

                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),

                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF503AA1),
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
                                    "Login",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(           //divide by OR
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("OR"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // GOOGLE
                      SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: signInWithGoogle,
                        
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 22,
                          width: 22,
                        ),

                        label: const Text(
                          "Continue with Google",
                          overflow: TextOverflow.ellipsis,
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                      const SizedBox(height: 2),

                      // PHONE BUTTON
                      TextButton(
                        onPressed: () {
                          showForgotPasswordPhoneDialog();
                        },
                        child: const Text("Forgot Password? Login with Phone"),
                      ),

                      const SizedBox(height: 0),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupPage()),
                          );
                        },
                        child: const Text("Don't have an account? \n Create Account",
                         textAlign: TextAlign.center,
                         style: TextStyle(fontSize: 13),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
  );
  }
  )
    );
  }
}