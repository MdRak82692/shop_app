import 'package:flutter/material.dart';
import '../utils/text.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData? icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(), color.withValues()],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(75),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        elevation: 8,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(title, style: style(16, color: Colors.white70)),
              const SizedBox(height: 8),
              Text(value.toStringAsFixed(2),
                  style: style(22, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
