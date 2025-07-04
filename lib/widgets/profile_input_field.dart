import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          decoration: InputDecoration(
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onBackground,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onBackground,
                width: 1,
              ),
            ),
            labelText: hintText?.tr(),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            hintStyle: TextStyle(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.background,
            isDense: false,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            prefixIcon: keyboardType == TextInputType.emailAddress
                ? Icon(Icons.email,
                    color: Theme.of(context).colorScheme.onBackground)
                : null,
          ),
        ),
      ],
    );
  }
}
