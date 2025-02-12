import 'package:flutter/material.dart';
import '../utils/text.dart';

class DropDownButton extends StatefulWidget {
  final String label;
  final List<String> items;
  final IconData icon;
  final String? selectedItem;
  final Function(String?)? onChanged;

  const DropDownButton({
    super.key,
    required this.label,
    required this.items,
    this.selectedItem,
    required this.icon,
    this.onChanged,
  });

  @override
  DropDownButtonState createState() => DropDownButtonState();
}

class DropDownButtonState extends State<DropDownButton> {
  String? currentSelection;

  @override
  void initState() {
    super.initState();
    currentSelection = widget.selectedItem;
  }

  @override
  void didUpdateWidget(covariant DropDownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      setState(() {
        currentSelection = widget.selectedItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: currentSelection,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: style(16, color: Colors.black),
          prefixIcon: Icon(widget.icon, color: Colors.blue),
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: style(16, color: Colors.black),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
