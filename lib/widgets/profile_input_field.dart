import 'package:flutter/material.dart';

class ProfileInputField extends StatelessWidget {
  final TextEditingController controller;
  // final String labelText;
  final String hintText;
  final TextInputType keyboardType;

  const ProfileInputField({
    super.key,
    required this.controller,
    // required this.labelText,
    this.hintText = '',
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: 1, // Ensure it's single line
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 16,
            color: Color(0xff000000),
          ),
          decoration: InputDecoration(
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            labelText: hintText, // Use hintText as labelText for the new style
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 18,
              color: Colors.black,
            ),
            filled: true,
            fillColor: const Color(0x00f2f2f3),
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            // Conditionally add prefixIcon if it's the email field
            prefixIcon: keyboardType == TextInputType.emailAddress
                ? const Icon(Icons.email)
                : null,
          ),
        ),
      ],
    );
  }
}
