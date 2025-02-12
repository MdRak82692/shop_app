import 'package:flutter/material.dart';
import 'text.dart';

void showCustomDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: style(20,
              color: (title == 'Error' || title == 'Login Failed')
                  ? Colors.red
                  : Colors.green),
        ),
        content: Text(
          message,
          style: style(15, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: style(15, color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}
