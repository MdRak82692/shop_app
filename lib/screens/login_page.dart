import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/admin/admin_dashboard.dart';
import 'staff/staff_products_sale.dart';
import '../utils/loading_display.dart';
import '../utils/show_dialog.dart';
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
  bool isPasswordVisible = false;

  void login() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        showCustomDialog(
            context, 'Error', 'Please enter both email and password.');
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential? adminCredential;
      try {
        adminCredential = await auth.signInWithEmailAndPassword(
            email: email, password: password);
      } catch (_) {
        adminCredential = null;
      }

      if (adminCredential != null) {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()));
        }
        return;
      }

      final adminQuery = await firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (adminQuery.docs.isNotEmpty &&
          adminQuery.docs.first['password'] == password) {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()));
        }
        return;
      }

      final userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (userQuery.docs.isNotEmpty &&
          userQuery.docs.first['password'] == password) {
        await userQuery.docs.first.reference
            .update({'lastSignedIn': FieldValue.serverTimestamp()});
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const StaffProductsSale()));
        }
        return;
      }

      throw FirebaseAuthException(
          code: 'invalid-credentials', message: 'Invalid email or password.');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showCustomDialog(
            context,
            'Login Failed',
            e.code == 'invalid-credentials'
                ? 'Invalid email or password.'
                : e.message ?? 'An unknown error occurred.');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(25),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(25),
              ),
            ),
          ),
          // Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_person, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  Text("Welcome Back",
                      style: style(
                        32,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 8),
                  Text("Sign in to continue",
                      style: style(18, color: Colors.white70)),
                  const SizedBox(height: 40),
                  buildTextField(emailCtrl, "Email", Icons.email),
                  const SizedBox(height: 20),
                  buildTextField(passwordCtrl, "Password", Icons.lock,
                      isPassword: true),
                  const SizedBox(height: 30),
                  isLoading
                      ? buildLoadingOverlay()
                      : ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 16),
                            elevation: 5,
                          ),
                          child: Text("Sign In",
                              style: style(
                                20,
                                color: Colors.blue,
                              )),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(229),
        hintText: hint,
        hintStyle: style(16, color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black54),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      obscureText: isPassword && !isPasswordVisible,
      style: style(16, color: Colors.black),
    );
  }
}
