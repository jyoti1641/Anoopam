// lib/screens/sahebji_gallery_screen.dart
import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/sahebji_ocassions.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/models/photo.dart'; // Import the Photo model
import 'photo_detail_screen.dart'; // Import the PhotoDetailScreen

class SahebjiGalleryScreen extends StatefulWidget {
  const SahebjiGalleryScreen({super.key});

  @override
  State<SahebjiGalleryScreen> createState() => _SahebjiGalleryScreenState();
}

class _SahebjiGalleryScreenState extends State<SahebjiGalleryScreen> {
  List<SahebjiOccasion> _occasions = [];
  List<String> _galleryImages = [];
  int? _selectedYear;
  SahebjiOccasion? _selectedOccasion;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final occasions = await PhotoApiService.getSahebjiOccasions();
      final photos = await PhotoApiService.getSahebjiGallery();

      if (!mounted) return;
      setState(() {
        _occasions = occasions;
        _galleryImages = photos;
        _selectedYear =
            DateTime.now().year; // Set the default year to the current year
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

  Future<void> _fetchGalleryPhotos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final photos = await PhotoApiService.getSahebjiGallery(
        year: _selectedYear,
        occasionId: _selectedOccasion?.id,
      );

      if (!mounted) return;
      setState(() {
        _galleryImages = photos;
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

  List<int> get yearsList {
    int currentYear = DateTime.now().year;
    return List<int>.generate(
      10,
      (index) => currentYear - index,
    ); // Generates a list for the last 10 years
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: const Text('Sahebji Gallery'),
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
                // Years Dropdown
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        hint: const Text('Years'),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedYear = newValue;
                          });
                          _fetchGalleryPhotos();
                        },
                        items: yearsList.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year.toString(),
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Occasions Dropdown
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SahebjiOccasion>(
                        value: _selectedOccasion,
                        hint: const Text('Occasion'),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (SahebjiOccasion? newValue) {
                          setState(() {
                            _selectedOccasion = newValue;
                          });
                          _fetchGalleryPhotos();
                        },
                        items: _occasions.map((SahebjiOccasion occasion) {
                          return DropdownMenuItem<SahebjiOccasion>(
                            value: occasion,
                            child: Text(
                              occasion.name,
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : (_errorMessage != null && _galleryImages.isEmpty)
                  ? const Expanded(
                      child: Center(
                          child: Text('No photos found for this selection.')))
                  : Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _galleryImages.length,
                        itemBuilder: (context, index) {
                          final imageUrl = _galleryImages[index];
                          return GestureDetector(
                            onTap: () {
                              // Create a temporary Photo object to pass to the detail screen
                              final tempPhoto = Photo(
                                id: index,
                                albumId: _selectedOccasion?.id ?? 0,
                                imageUrl: imageUrl,
                                country: '',
                                state: '',
                                lastUpdated: DateTime.now(),
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PhotoDetailScreen(photo: tempPhoto),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
