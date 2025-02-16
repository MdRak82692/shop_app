import 'package:flutter/material.dart';
import '../utils/text.dart';

class AddEditTitleSection extends StatelessWidget {
  final String title;
  final Function targetWidget;

  const AddEditTitleSection({
    super.key,
    required this.title,
    required this.targetWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    title,
                    style: style(24, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => targetWidget(),
                    ),
                  ),
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
        const Divider(height: 1, thickness: 1, color: Colors.grey),
      ],
    );
  }
}
