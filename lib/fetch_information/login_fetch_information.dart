import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/staff/staff_products_sale.dart';
import '../utils/password_strong.dart';
import '../utils/show_dialog.dart';

class LoginFetchInformation {
  final FirebaseFirestore firestore;
  final Function(void Function()) setState;
  final bool Function() isMounted;
  final void Function(Widget) navigateTo;

  LoginFetchInformation({
    required this.firestore,
    required this.setState,
    required this.isMounted,
    required this.navigateTo,
  });

  final auth = FirebaseAuth.instance;

  String passwordStrength = '';
  bool isLoading = false;
  final passwordChecker = PasswordStrengthChecker();

  void login(BuildContext context, TextEditingController emailCtrl,
      TextEditingController passwordCtrl) async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (isMounted()) {
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
          email: email,
          password: password,
        );
      } catch (_) {
        adminCredential = null;
      }

      if (adminCredential != null) {
        if (isMounted()) {
          navigateTo(const AdminDashboard());
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
        if (isMounted()) {
          navigateTo(const AdminDashboard());
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

        if (isMounted()) {
          navigateTo(const StaffProductsSale());
        }
        return;
      }

      throw FirebaseAuthException(
        code: 'invalid-credentials',
        message: 'Invalid email or password.',
      );
    } on FirebaseAuthException catch (e) {
      if (isMounted()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomDialog(
            context,
            'Login Failed',
            e.code == 'invalid-credentials'
                ? 'Invalid email or password.'
                : e.message ?? 'An unknown error occurred.',
          );
        });
      }
    } finally {
      if (isMounted()) {
        setState(() => isLoading = false);
      }
    }
  }
}
