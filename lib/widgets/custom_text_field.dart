import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.suffixIcon,
    super.key,
  });

  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: textStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            hintStyle ??
            const TextStyle(fontSize: 20, color: AppColors.fieldText),
        prefixIcon: prefixIcon,
        prefixIconConstraints: prefixIconConstraints,
        suffixIcon: suffixIcon,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.link),
        ),
      ),
    );
  }
}
