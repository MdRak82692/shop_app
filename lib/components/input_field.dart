import 'package:flutter/material.dart';
import '../utils/text.dart';

class InputField extends StatefulWidget {
  final dynamic controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final bool readOnly;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final Color? suffixIconColor;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.readOnly = false,
    this.onChanged,
    this.suffixIcon,
    this.suffixIconColor,
  });

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscure && !_isPasswordVisible,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: style(16, color: Colors.black),
          prefixIcon: Icon(widget.icon, color: Colors.blue),
          suffixIcon: widget.suffixIcon ??
              (widget.obscure
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      color: widget.suffixIconColor ?? Colors.blue,
                    )
                  : null),
        ),
        style: style(16, color: Colors.black),
      ),
    );
  }
}
