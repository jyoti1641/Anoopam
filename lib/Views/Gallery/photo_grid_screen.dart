// lib/screens/photo_grid_screen.dart
import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:anoopam_mission/widgets/filter_dialog.dart';
import 'package:anoopam_mission/widgets/photo_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import 'photo_detail_screen.dart';

class PhotoGridScreen extends StatefulWidget {
  final int albumId;
  final String albumName;

  const PhotoGridScreen({
    Key? key,
    required this.albumId,
    required this.albumName,
  }) : super(key: key);

  @override
  State<PhotoGridScreen> createState() => _PhotoGridScreenState();
}

class _PhotoGridScreenState extends State<PhotoGridScreen> {
  List<Photo> _allPhotos = [];
  List<Photo> _filteredPhotos = [];
  bool _isLoading = false;
  String? _errorMessage;
  final PhotoRepository _repository = PhotoRepository();

  String? _selectedCountry;
  String? _selectedState;
  DateTime? _selectedLastUpdated;

  // Variables for displaying current filter status
  String _currentLocationDisplay = '';
  String _currentDateDisplay = '';

  @override
  void initState() {
    super.initState();
    print('PhotoGridScreen for Album ID: ${widget.albumId}'); // Debug print
    _fetchPhotosForAlbum();
  }

  @override
  void dispose() {
    _repository.dispose(); // Dispose the client when the state is disposed
    super.dispose();
  }

  Future<void> _fetchPhotosForAlbum() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedPhotos = await _repository.getPhotosForAlbum(widget.albumId);
      setState(() {
        _allPhotos = fetchedPhotos;
        print(
            'Fetched Photos for ${widget.albumId}: ${_allPhotos.length} items'); // Debug print
        print(
            'Countries in fetched photos: ${_allPhotos.map((p) => p.country).toSet().toList()}');
        print(
            'States in fetched photos: ${_allPhotos.map((p) => p.state).toSet().toList()}');

        // Set initial display based on fetched photos
        _setInitialFilterDisplay();
        _applyFilters(); // Apply initial filters (which are none at this point)
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Error fetching photos: $e'); // Debug print
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setInitialFilterDisplay() {
    if (_allPhotos.isEmpty) {
      _currentLocationDisplay = 'No Location Info';
      _currentDateDisplay = 'No Date Info';
      return;
    }

    // Determine initial location display
    String defaultCountry = _allPhotos.first.country;
    String defaultState = _allPhotos.first.state;

    // Check if all photos share the same country and state
    final allSameCountry =
        _allPhotos.every((photo) => photo.country == defaultCountry);
    final allSameState =
        _allPhotos.every((photo) => photo.state == defaultState);

    if (allSameState && allSameCountry) {
      _currentLocationDisplay = '$defaultState - $defaultCountry';
    } else if (allSameCountry) {
      _currentLocationDisplay = 'Various States - $defaultCountry';
    } else {
      _currentLocationDisplay = 'Various Locations';
    }

    // Determine initial date display (earliest date in the album)
    DateTime? earliestDate;
    for (var photo in _allPhotos) {
      if (earliestDate == null || photo.lastUpdated.isBefore(earliestDate)) {
        earliestDate = photo.lastUpdated;
      }
    }

    if (earliestDate != null) {
      _currentDateDisplay =
          'Last updated after ${DateFormat('dd MMM yyy').format(earliestDate)}';
    } else {
      _currentDateDisplay = 'No Date Info';
    }
  }

  void _applyFilters() {
    List<Photo> tempFiltered = List.from(_allPhotos);

    // Filter logic
    if (_selectedCountry != null &&
        _selectedCountry!.isNotEmpty &&
        _selectedCountry != 'All') {
      tempFiltered = tempFiltered
          .where((photo) => photo.country == _selectedCountry)
          .toList();
    }
    if (_selectedState != null &&
        _selectedState!.isNotEmpty &&
        _selectedState != 'All') {
      tempFiltered =
          tempFiltered.where((photo) => photo.state == _selectedState).toList();
    }
    if (_selectedLastUpdated != null) {
      tempFiltered = tempFiltered
          .where(
            (photo) => photo.lastUpdated.isAfter(_selectedLastUpdated!),
          )
          .toList();
    }

    // Update display text based on active filters or reset to initial album data
    if (_areFiltersActive) {
      String location = '';
      if (_selectedState != null &&
          _selectedState!.isNotEmpty &&
          _selectedState != 'All') {
        location += _selectedState!;
      }
      if (_selectedCountry != null &&
          _selectedCountry!.isNotEmpty &&
          _selectedCountry != 'All') {
        if (location.isNotEmpty) {
          location += ' - ';
        }
        location += _selectedCountry!;
      }
      _currentLocationDisplay = location.isEmpty ? 'All Places' : location;

      if (_selectedLastUpdated != null) {
        _currentDateDisplay =
            'After ${DateFormat('dd MMM BCE').format(_selectedLastUpdated!)}';
      } else {
        _currentDateDisplay = 'All Times';
      }
    } else {
      // If no filters are active, revert to the initial album display
      _setInitialFilterDisplay();
    }

    setState(() {
      _filteredPhotos = tempFiltered;
    });
  }

  Widget _buildFilterBar() {
    // Get unique countries and states from _allPhotos for filter options
    final List<String> uniqueCountries =
        {'All', ..._allPhotos.map((photo) => photo.country)}.toList()..sort();
    final List<String> uniqueStates =
        {'All', ..._allPhotos.map((photo) => photo.state)}.toList()..sort();

    return FilterBar(
      countries: uniqueCountries,
      states: uniqueStates,
      initialCountry: _selectedCountry,
      initialState: _selectedState,
      initialLastUpdated: _selectedLastUpdated,
      onApply: (country, state, lastUpdated) {
        setState(() {
          _selectedCountry = country;
          _selectedState = state;
          _selectedLastUpdated = lastUpdated;
        });
        _applyFilters(); // Apply new filters
      },
    );
  }

  bool get _areFiltersActive =>
      (_selectedCountry != null && _selectedCountry != 'All') ||
      (_selectedState != null && _selectedState != 'All') ||
      _selectedLastUpdated != null;

  void _clearFilters() {
    setState(() {
      _selectedCountry = null;
      _selectedState = null;
      _selectedLastUpdated = null;
    });
    _applyFilters(); // This will now call _setInitialFilterDisplay() via the else block
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumName), // Only album name in the app bar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : Column(
                  // Use a Column for the body to stack widgets
                  children: [
                    // Inline Filter Bar
                    _buildFilterBar(),

                    // Display filter status below the filter bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentLocationDisplay,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium, // Slightly larger for visibility
                          ),
                          Text(
                            _currentDateDisplay,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall, // Slightly smaller
                          ),
                        ],
                      ),
                    ),

                    // The rest of the body content (GridView.builder)
                    Expanded(
                      // Wrap GridView.builder in Expanded to fill remaining space
                      child: _filteredPhotos.isEmpty
                          ? Center(
                              child: Text(
                                _areFiltersActive
                                    ? 'No photos found for this album with current filters.'
                                    : 'No photos found for this album.',
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _filteredPhotos.length,
                              itemBuilder: (context, index) {
                                final photo = _filteredPhotos[index];
                                return PhotoCard(
                                  photo: photo,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PhotoDetailScreen(photo: photo),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
