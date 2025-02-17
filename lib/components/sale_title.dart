import '../utils/text.dart';
import 'package:flutter/material.dart';

class SaleTitle extends StatelessWidget {
  final String title;
  final Color color;

  const SaleTitle({
    super.key,
    required this.title,
    this.color = Colors.lightBlue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withAlpha(90),
              color.withAlpha(60),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(55),
              blurRadius: 8.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: color.withAlpha(76),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              title,
              style: style(
                24,
                color: color.withAlpha(230),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
