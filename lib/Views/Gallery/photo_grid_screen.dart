// lib/screens/photo_grid_screen.dart
import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:anoopam_mission/widgets/filter_dialog.dart';
import 'package:anoopam_mission/widgets/photo_card.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    print('PhotoGridScreen for Album ID: ${widget.albumId}'); // Debug print
    _fetchPhotosForAlbum();
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
          'Fetched Photos for ${widget.albumId}: ${_allPhotos.length} items',
        ); // Debug print
        // Print countries/states found in the fetched photos
        print(
          'Countries in fetched photos: ${_allPhotos.map((p) => p.country).toSet().toList()}',
        );
        print(
          'States in fetched photos: ${_allPhotos.map((p) => p.state).toSet().toList()}',
        );

        _applyFilters();
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

  void _applyFilters() {
    List<Photo> tempFiltered = List.from(_allPhotos);

    if (_selectedCountry != null &&
        _selectedCountry!.isNotEmpty &&
        _selectedCountry != 'All') {
      tempFiltered =
          tempFiltered
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
      tempFiltered =
          tempFiltered
              .where(
                (photo) => photo.lastUpdated.isAfter(_selectedLastUpdated!),
              )
              .toList();
    }

    setState(() {
      _filteredPhotos = tempFiltered;
    });
  }

  void _showFilterDialog(BuildContext context) {
    // Get unique countries and states from _allPhotos for filter options
    final List<String> uniqueCountries =
        {'All', ..._allPhotos.map((photo) => photo.country)}.toList()..sort();
    final List<String> uniqueStates =
        {'All', ..._allPhotos.map((photo) => photo.state)}.toList()..sort();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
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
            _applyFilters();
          },
        );
      },
    );
  }

  bool get _areFiltersActive =>
      _selectedCountry != null ||
      _selectedState != null ||
      _selectedLastUpdated != null;

  void _clearFilters() {
    setState(() {
      _selectedCountry = null;
      _selectedState = null;
      _selectedLastUpdated = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of your build method remains the same)
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumName),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          if (_areFiltersActive)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _filteredPhotos.isEmpty
              ? const Center(
                child: Text(
                  'No photos found for this album with current filters.',
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          builder: (context) => PhotoDetailScreen(photo: photo),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
