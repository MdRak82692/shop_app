import 'package:flutter/material.dart';
import 'show_dialog.dart';
import 'text.dart';

class PasswordStrengthChecker {
  String passwordStrength = '';

  bool isPasswordStrong(String password, Function(String) setPasswordStrength) {
    int strengthScore = 0;

    if (password.length >= 7) strengthScore++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strengthScore++;
    if (RegExp(r'[a-z]').hasMatch(password)) strengthScore++;
    if (RegExp(r'[0-9]').hasMatch(password)) strengthScore++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strengthScore++;

    if (strengthScore >= 5) {
      passwordStrength = 'Very Strong';
    } else if (strengthScore >= 4) {
      passwordStrength = 'Strong';
    } else if (strengthScore >= 3) {
      passwordStrength = 'Medium';
    } else {
      passwordStrength = 'Weak';
    }

    setPasswordStrength(passwordStrength);

    return strengthScore >= 3;
  }

  String getPasswordStrengthErrorMessage(BuildContext context) {
    String errorMessage = '';

    switch (passwordStrength) {
      case 'Weak':
        errorMessage =
            'Password is Weak. Please ensure it meets the required criteria.';
        break;
      case 'Medium':
        errorMessage =
            'Password is Medium. Consider adding more complexity for better security.';
        break;
      case 'Strong':
      case 'Very Strong':
        return '';
      default:
        errorMessage = 'Invalid Password Criteria.';
    }

    if (passwordStrength != 'Strong' && passwordStrength != 'Very Strong') {
      showCustomDialog(context, 'Error', errorMessage);
    }

    return errorMessage;
  }
}

Widget buildPasswordStrengthIndicator(String passwordStrength) {
  return Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(top: 5.0, left: 40.0),
    child: Text(
      passwordStrength,
      style: style(
        18,
        color: passwordStrength == 'Very Strong'
            ? Colors.green
            : passwordStrength == 'Strong'
                ? Colors.blue
                : passwordStrength == 'Medium'
                    ? Colors.black
                    : Colors.red,
      ),
    ),
  );
}
