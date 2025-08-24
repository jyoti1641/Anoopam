// lib/screens/thakorji_darshan_screen.dart

import 'package:anoopam_mission/Views/Gallery/photo_detail_screen.dart';
import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:anoopam_mission/models/thakorji_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ThakorjiDarshanScreen extends StatefulWidget {
  const ThakorjiDarshanScreen({super.key});

  @override
  State<ThakorjiDarshanScreen> createState() => _ThakorjiDarshanScreenState();
}

class _ThakorjiDarshanScreenState extends State<ThakorjiDarshanScreen> {
  List<Country> _countries = [];
  List<CenterModel> _centers = [];
  Country? _selectedCountry;
  CenterModel? _selectedCenter;
  DateTime? _selectedDate;
  ThakorjiDarshanDetails? _thakorjiPhotos;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    // This is where you would cancel timers or streams if you had any.
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final countries = await PhotoApiService.getThakorjiCountries();
      if (!mounted) return;
      if (countries.isEmpty) {
        throw Exception('No countries found.');
      }
      final firstCountry = countries.first;
      // print(firstCountry.name);
      final centers = await PhotoApiService.getThakorjiCenters(firstCountry.id);
      if (!mounted) return;
      if (centers.isEmpty) {
        throw Exception('No centers found for the selected country.');
      }
      final firstCenter = centers.first;
      final thakorjiPhotos =
          await PhotoApiService.getThakorjiPhotos(firstCenter.id);
      if (!mounted) return;

      setState(() {
        _countries = countries;
        _centers = centers;
        _selectedCountry = firstCountry;
        _selectedCenter = firstCenter;
        _thakorjiPhotos = thakorjiPhotos;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCenters(Country country) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final centers = await PhotoApiService.getThakorjiCenters(country.id);
      if (!mounted) return;
      if (centers.isEmpty) {
        setState(() {
          _centers = [];
          _selectedCenter = null;
          _thakorjiPhotos = null;
        });
        throw Exception('No centers found for this country.');
      }

      final firstCenter = centers.first;
      final thakorjiPhotos =
          await PhotoApiService.getThakorjiPhotos(firstCenter.id);
      if (!mounted) return;

      setState(() {
        _centers = centers;
        _selectedCountry = country;
        _selectedCenter = firstCenter;
        _thakorjiPhotos = thakorjiPhotos;
        _selectedDate = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPhotosForCenter(CenterModel center) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final thakorjiPhotos = await PhotoApiService.getThakorjiPhotos(center.id);
      if (!mounted) return;
      setState(() {
        _selectedCenter = center;
        _thakorjiPhotos = thakorjiPhotos;
        _selectedDate = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPhotosForDate(DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final formattedDate = DateFormat('yyyyMMdd').format(date);

    try {
      final thakorjiPhotos = await PhotoApiService.getThakorjiPhotos(
        _selectedCenter!.id,
        date: formattedDate,
      );
      if (!mounted) return;
      setState(() {
        _selectedDate = date;
        _thakorjiPhotos = thakorjiPhotos;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: const Text('Thakorji Darshan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Country>(
                        value: _selectedCountry,
                        hint: const Text('Select Country'),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (Country? newValue) {
                          if (newValue != null) {
                            _fetchCenters(newValue);
                          }
                        },
                        items: _countries.map((Country country) {
                          return DropdownMenuItem<Country>(
                            value: country,
                            child: Text(country.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && _selectedCenter != null) {
                          _fetchPhotosForDate(picked);
                        }
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/calendar.svg',
                            // color: Colors.white,
                            height: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : DateFormat.yMMMd().format(_selectedDate!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 35,
              child: _centers.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _centers.length,
                      itemBuilder: (context, index) {
                        final center = _centers[index];
                        final isSelected = _selectedCenter?.id == center.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            selectedColor: const Color(0xFF034DA2),
                            disabledColor: Colors.grey,
                            backgroundColor: Colors.grey.shade200,
                            label: Text(
                              center.title,
                              textAlign: TextAlign.center,
                            ),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20), // Increase this value as needed
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey,
                              ),
                            ),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                _fetchPhotosForCenter(center);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : _errorMessage != null
                  ? Expanded(child: Center(child: Text(_errorMessage!)))
                  : _thakorjiPhotos == null
                      ? const Expanded(
                          child: Center(
                              child: Text(
                                  'No Thakorji Darshan photos available.')))
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    _thakorjiPhotos!.title.split(' ')[0],
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF034DA2),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/calendar.svg',
                                        // color: Colors.white,
                                        height: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        DateFormat.yMMMMd().format(
                                            DateTime.parse(_thakorjiPhotos!
                                                .timestamp
                                                .split('-')
                                                .reversed
                                                .join('-'))),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GridView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(16),
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: _thakorjiPhotos!.images.length,
                                  itemBuilder: (context, index) {
                                    final imageUrl =
                                        _thakorjiPhotos!.images[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // Create a temporary Photo object with the URL and a dummy ID
                                        final tempPhoto = Photo(
                                          id: index, // Use index or a unique ID if available
                                          albumId: _selectedCenter!.id,
                                          imageUrl: imageUrl,
                                          country: _selectedCountry!.name,
                                          state: _selectedCenter!.title,
                                          lastUpdated: DateTime.now(),
                                        );

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PhotoDetailScreen(
                                                    photo: tempPhoto),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                          color: Colors.grey)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
        ],
      ),
    );
  }
}
