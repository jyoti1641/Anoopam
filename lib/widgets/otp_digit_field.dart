// lib/widgets/otp_digit_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autoFocus;
  final FocusNode? nextFocusNode; // New: Optional next focus node
  final FocusNode? prevFocusNode; // New: Optional previous focus node (for backspace)

  const OtpDigitField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.autoFocus = false,
    this.nextFocusNode, // Initialize new parameters
    this.prevFocusNode, // Initialize new parameters
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, // Width for each OTP digit box
      height: 50, // Height for each OTP digit box
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey, width: 1),
        color: const Color(0xfff5f5f5), // Light background for the boxes
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1, // Only one digit per field
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Ensure only digits are entered
        ],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 24,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: "", // Hide the default character counter
          border: InputBorder.none, // Remove default TextField border
        ),
        onChanged: (value) {
          if (value.length == 1) {
            // If a digit is entered, move focus to the next field
            if (nextFocusNode != null) {
              nextFocusNode!.requestFocus();
            } else {
              // If it's the last digit, unfocus to hide the keyboard
              focusNode.unfocus();
            }
          } else if (value.isEmpty) {
            // If a digit is deleted (backspace), move focus to the previous field
            if (prevFocusNode != null) {
              prevFocusNode!.requestFocus();
            }
          }
          // You might still want to notify the parent if necessary for verification
          // For this specific case, the parent's addListener on controller still works.
          // If you *only* wanted to use onChanged here, you'd need to pass a callback to the parent.
        },
      ),
    );
  }
}
