import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/input_field.dart';
import '../firestore/login_fetch_information.dart';
import '../utils/password_strong.dart';
import '../utils/loading_display.dart';
import '../utils/text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isLoading = false;
  final passwordChecker = PasswordStrengthChecker();
  LoginFetchInformation? fetchInformation;

  @override
  void initState() {
    super.initState();
    fetchInformation = LoginFetchInformation(
      firestore: FirebaseFirestore.instance,
      setState: setState,
      isMounted: () => mounted,
      navigateTo: (widget) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => widget));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.blue.shade400],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(25),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: -100,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(25),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(25),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 150,
                    right: -100,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(25),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Adventure starts here",
                            style: style(
                              32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Create an account to join our community and explore the world of possibilities.",
                            style: style(18, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_person,
                            size: 100, color: Colors.blue),
                        const SizedBox(height: 20),
                        Text(
                          "Hello! Welcome back",
                          style: style(
                            24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Login to your account to continue",
                          style: style(16, color: Colors.grey),
                        ),
                        const SizedBox(height: 40),
                        InputField(
                          controller: emailCtrl,
                          label: "Email",
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 20),
                        InputField(
                          controller: passwordCtrl,
                          label: "Password",
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 20),
                        isLoading
                            ? buildLoadingOverlay()
                            : ElevatedButton(
                                onPressed: () => fetchInformation!
                                    .login(context, emailCtrl, passwordCtrl),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 16),
                                ),
                                child: Text(
                                  "Login",
                                  style: style(
                                    20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),
                        Text(
                          "Or login with",
                          style: style(14, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata,
                                size: 40, color: Colors.red),
                            SizedBox(width: 20),
                            Icon(Icons.facebook, size: 40, color: Colors.blue),
                            SizedBox(width: 20),
                            Icon(Icons.apple, size: 40, color: Colors.black),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Don't have an account? Create Account",
                            style: style(
                              14,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
