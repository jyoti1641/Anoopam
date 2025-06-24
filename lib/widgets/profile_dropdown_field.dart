import 'package:flutter/material.dart';

class ProfileDropdownField extends StatelessWidget {
  final String labelText; // This will be the floating label
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const ProfileDropdownField({
    super.key,
    required this.labelText, // Passed as the label text that floats
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      // The hint property is what's displayed *inside* the field when `value` is null.
      // We concatenate "Select " with the labelText for the desired display.
      hint: Text(
        'Select $labelText',
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 16, // Use 16 for the text inside, consistent with TextField's input style
          color: Colors.black, // Keep it black
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
      isExpanded: true,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 16, // Font size for items in the dropdown list
              color: Color(0xff000000),
            ),
          ),
        );
      }).toList(),
      dropdownColor: Colors.white,
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
        // The labelText for InputDecoration is what creates the floating label effect.
        // It will be "Gender" or "Age Group" and will float up when an item is selected or the field is focused.
        labelText: labelText,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 18, // This is the font size when the label is *not* floating
          color: Colors.black,
        ),
        filled: true,
        fillColor: const Color(0x00f2f2f3),
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      // Style for the selected item displayed in the dropdown field itself
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xff000000),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}