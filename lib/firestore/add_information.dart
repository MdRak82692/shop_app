import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/show_dialog.dart';
import '../utils/password_strong.dart';

Future<void> addInformation({
  required BuildContext context,
  required Widget targetWidget,
  required Map<String, dynamic> controllers,
  required FirebaseFirestore firestore,
  required bool isLoading,
  required Function setState,
  PasswordStrengthChecker? passwordChecker,
  required String collectionName,
  String? name,
  String? option,
  String? name1,
  String? option1,
  required List<String> fieldsToSubmit,
  bool addTimestamp = false,
}) async {
  if (fieldsToSubmit.any((field) =>
      controllers[field] == null || controllers[field].toString().isEmpty)) {
    if (!context.mounted) return;
    showCustomDialog(context, 'Error', 'All Fields are Required.');
    return;
  }

  if (fieldsToSubmit.contains(option)) {
    if (await isExists(
      firestore,
      collectionName,
      controllers[name]?.toString() ?? '',
      option!,
    )) {
      if (!context.mounted) return;
      showCustomDialog(context, 'Error', 'This $name already Exists.');
      return;
    }
  }

  if (fieldsToSubmit.contains(option1)) {
    if (await isExists1(
      firestore,
      collectionName,
      controllers[name1]?.toString() ?? '',
      option1!,
    )) {
      if (!context.mounted) return;
      showCustomDialog(context, 'Error', 'This $name1 already Exists.');
      return;
    }
  }

  if (fieldsToSubmit.contains('password')) {
    String password = controllers['password']?.toString() ?? '';

    if (!passwordChecker!.isPasswordStrong(password, (_) {})) {
      if (!context.mounted) return;
      showCustomDialog(
        context,
        'Error',
        passwordChecker.getPasswordStrengthErrorMessage(context),
      );
      return;
    }
  }

  setState(() => isLoading = true);

  try {
    Map<String, dynamic> userData = {};

    for (var field in fieldsToSubmit) {
      userData[field] = controllers[field];
    }

    if (addTimestamp) {
      userData['time'] = FieldValue.serverTimestamp();
    }

    await firestore.collection(collectionName).add(userData);

    if (!context.mounted) return;
    showCustomDialog(context, 'Successful', 'Information Added Successfully.');

    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => targetWidget));
  } finally {
    if (context.mounted) {
      setState(() => isLoading = false);
    }
  }
}

Future<bool> isExists(FirebaseFirestore firestore, String collectionName,
    String name, String option) async {
  try {
    var querySnapshot = await firestore
        .collection(collectionName)
        .where(option, isEqualTo: name)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
}

Future<bool> isExists1(FirebaseFirestore firestore, String collectionName,
    String name1, String option1) async {
  try {
    var querySnapshot = await firestore
        .collection(collectionName)
        .where(option1, isEqualTo: name1)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
}
