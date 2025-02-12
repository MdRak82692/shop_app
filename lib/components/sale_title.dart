import '../utils/text.dart';
import 'package:flutter/material.dart';

class SaleTitle extends StatelessWidget {
  final String title;
  final Color color;

  const SaleTitle({
    super.key,
    required this.title,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(),
              color.withValues(),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 50.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(title, style: style(20, color: Colors.green.shade800)),
          ),
        ),
      ),
    );
  }
}
