import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
        'profile.select'.tr(namedArgs: {'label': labelText.tr()}),
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 16,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down,
          color: Theme.of(context).colorScheme.onBackground),
      isExpanded: true,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        );
      }).toList(),
      dropdownColor: Theme.of(context).colorScheme.background,
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
        // The labelText for InputDecoration is what creates the floating label effect.
        // It will be "Gender" or "Age Group" and will float up when an item is selected or the field is focused.
        labelText: labelText.tr(),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 18,
          color: Theme.of(context).colorScheme.onBackground,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.background,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      // Style for the selected item displayed in the dropdown field itself
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onBackground,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
