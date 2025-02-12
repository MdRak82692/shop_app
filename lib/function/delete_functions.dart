import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/show_dialog.dart';
import '../utils/text.dart';

void deleteFunction(
    BuildContext context, String userId, String collectionName) async {
  final firestore = FirebaseFirestore.instance;

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Confirm Delete',
        style: style(20, color: Colors.red),
      ),
      content: Text(
        'Are you sure you want to delete this item?',
        style: style(15, color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: style(15, color: Colors.green),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Delete',
            style: style(15, color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await firestore.collection(collectionName).doc(userId).delete();

    if (!context.mounted) return;

    showCustomDialog(
      context,
      'Successful',
      'Item deleted successfully',
    );
  }
}
