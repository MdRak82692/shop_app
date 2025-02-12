import 'package:flutter/material.dart';
import '../utils/text.dart';

class AddEditTitleSection extends StatelessWidget {
  final String title;

  const AddEditTitleSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allows horizontal scrolling
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: style(24, color: Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                label: Text(
                  "Back",
                  style: style(16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
