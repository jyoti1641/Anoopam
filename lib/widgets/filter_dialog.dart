// lib/widgets/filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterBar extends StatefulWidget {
  final List<String> countries;
  final List<String> states;
  final String? initialCountry;
  final String? initialState;
  final DateTime? initialLastUpdated;
  final Function(String? country, String? state, DateTime? lastUpdated) onApply;

  const FilterBar({
    Key? key,
    required this.countries,
    required this.states,
    this.initialCountry,
    this.initialState,
    this.initialLastUpdated,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String? _selectedCountry;
  String? _selectedState;
  DateTime? _selectedLastUpdated;
  String? _selectedCity;

  // Sample city data - you can replace with actual data
  final List<String> _cities = [
    'Amdavad',
    'Mogri',
    'Khargar',
    'Surat',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai'
  ];

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
      _applyFilters();
    }
  }

  void _applyFilters() {
    widget.onApply(
      _selectedCountry == 'All' ? null : _selectedCountry,
      _selectedState == 'All' ? null : _selectedState,
      _selectedLastUpdated,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic sizing based on screen dimensions
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    // Responsive spacing and sizing
    final horizontalPadding =
        isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    final verticalPadding =
        isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    final spacing = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    final fontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final chipHeight = isSmallScreen ? 32.0 : (isMediumScreen ? 36.0 : 40.0);
    final borderRadius = isSmallScreen ? 20.0 : (isMediumScreen ? 25.0 : 30.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main filter row - responsive layout
              if (isSmallScreen) ...[
                // Small screen: Stack vertically
                Column(
                  children: [
                    // Country Dropdown
                    _buildCountryDropdown(isDark, fontSize, borderRadius),
                    SizedBox(height: spacing),
                    // Calendar Button
                    _buildCalendarButton(isDark, fontSize, borderRadius),
                  ],
                ),
              ] else ...[
                // Medium and large screens: Horizontal layout
                Row(
                  children: [
                    // Country Dropdown
                    Expanded(
                      flex: isLargeScreen ? 3 : 2,
                      child:
                          _buildCountryDropdown(isDark, fontSize, borderRadius),
                    ),
                    SizedBox(width: spacing),
                    // Calendar Button
                    Expanded(
                      flex: isLargeScreen ? 2 : 1,
                      child:
                          _buildCalendarButton(isDark, fontSize, borderRadius),
                    ),
                  ],
                ),
              ],

              SizedBox(height: spacing),

              // City Filter Chips - always horizontal scrollable
              _buildCityChips(isDark, fontSize, chipHeight, spacing),

              // Selected date display
              if (_selectedLastUpdated != null) ...[
                SizedBox(height: spacing),
                _buildSelectedDateDisplay(isDark, fontSize),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountryDropdown(
      bool isDark, double fontSize, double borderRadius) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCountry,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: fontSize * 1.2,
            vertical: fontSize * 0.8,
          ),
          border: InputBorder.none,
          hintText: 'Country',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: fontSize,
          ),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: fontSize,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          size: fontSize * 1.2,
        ),
        items: widget.countries.map((country) {
          return DropdownMenuItem(
            value: country,
            child: Text(
              country,
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCountry = value;
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildCalendarButton(
      bool isDark, double fontSize, double borderRadius) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () => _selectDate(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: fontSize * 1.2,
            vertical: fontSize * 0.8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: fontSize * 1.1,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              SizedBox(width: fontSize * 0.3),
              Flexible(
                child: Text(
                  'Calendar',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: fontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityChips(
      bool isDark, double fontSize, double chipHeight, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cities',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: spacing * 0.5),
        SizedBox(
          height: chipHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _cities.map((city) {
                final isSelected = _selectedCity == city;

                return Padding(
                  padding: EdgeInsets.only(right: spacing * 0.5),
                  child: ChoiceChip(
                    label: Text(
                      city,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        fontSize: fontSize * 0.9,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: isDark ? Colors.blue[700] : Colors.blue[600],
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[200],
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? Colors.blue[600]! : Colors.blue[500]!)
                          : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(chipHeight * 0.5),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCity = selected ? city : null;
                      });
                      _applyFilters();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDateDisplay(bool isDark, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.8,
        vertical: fontSize * 0.4,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue[900] : Colors.blue[50],
        borderRadius: BorderRadius.circular(fontSize * 1.2),
        border: Border.all(
          color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: fontSize * 0.9,
            color: isDark ? Colors.blue[300] : Colors.blue[700],
          ),
          SizedBox(width: fontSize * 0.4),
          Flexible(
            child: Text(
              'Selected: ${DateFormat('dd MMM yyyy').format(_selectedLastUpdated!)}',
              style: TextStyle(
                fontSize: fontSize * 0.8,
                color: isDark ? Colors.blue[300] : Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
