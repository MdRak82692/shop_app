import 'package:flutter/material.dart';
import '../utils/text.dart';

class TitleSection extends StatelessWidget {
  final String title;
  final Widget? targetWidget;
  final bool addIcon;

  const TitleSection({
    super.key,
    required this.title,
    this.targetWidget,
    required this.addIcon,
  }) : assert(
          addIcon == false || targetWidget != null,
          'targetWidget must not be null if addIcon is true',
        );

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
              if (addIcon && targetWidget != null)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => targetWidget!,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline,
                      size: 28, color: Colors.blue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.grey),
      ],
    );
  }
}
