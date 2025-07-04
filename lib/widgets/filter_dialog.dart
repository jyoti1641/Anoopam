// lib/widgets/filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterDialog extends StatefulWidget {
  final List<String> countries;
  final List<String> states;
  final String? initialCountry;
  final String? initialState;
  final DateTime? initialLastUpdated;
  final Function(String? country, String? state, DateTime? lastUpdated) onApply;

  const FilterDialog({
    Key? key,
    required this.countries, // This is where the lists are received
    required this.states, // This is where the lists are received
    this.initialCountry,
    this.initialState,
    this.initialLastUpdated,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedCountry;
  String? _selectedState;
  DateTime? _selectedLastUpdated;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry;
    _selectedState = widget.initialState;
    _selectedLastUpdated = widget.initialLastUpdated;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedLastUpdated ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedLastUpdated) {
      setState(() {
        _selectedLastUpdated = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('filterDialog.title'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration:
                  InputDecoration(labelText: 'filterDialog.country'.tr()),
              items: widget.countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: InputDecoration(labelText: 'filterDialog.state'.tr()),
              items: widget.states.map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('filterDialog.lastUpdatedAfter'.tr()),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 05,
                horizontal: 02,
              ),
              subtitle: Text(
                _selectedLastUpdated == null
                    ? 'filterDialog.selectDate'.tr()
                    : DateFormat('yyyy-MM-dd').format(_selectedLastUpdated!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('filterDialog.cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(
              _selectedCountry == 'All' ? null : _selectedCountry,
              _selectedState == 'All' ? null : _selectedState,
              _selectedLastUpdated,
            );
            Navigator.of(context).pop();
          },
          child: Text('filterDialog.apply'.tr()),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCountry = null;
              _selectedState = null;
              _selectedLastUpdated = null;
            });
            widget.onApply(null, null, null);
            Navigator.of(context).pop();
          },
          child: Text('filterDialog.clearFilters'.tr()),
        ),
      ],
    );
  }
}
