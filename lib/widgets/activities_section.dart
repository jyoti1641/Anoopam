import 'package:anoopam_mission/Views/Gallery/photo_detail_screen.dart';
import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivitiesSection extends StatefulWidget {
  const ActivitiesSection({super.key});

  @override
  State<ActivitiesSection> createState() => _ActivitiesSectionState();
}

class _ActivitiesSectionState extends State<ActivitiesSection> {
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
    _fetchPhotosForAlbum();
  }

  Future<void> _fetchPhotosForAlbum() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedPhotos = await _repository.activities();
      setState(() {
        _allPhotos = fetchedPhotos;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              const Image(
                image: AssetImage('assets/icons/activity.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text(
                'menu.activities'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.0,
              ),
              itemCount: _filteredPhotos.length,
              itemBuilder: (context, index) {
                // Sort the _filteredPhotos list based on the lastUpdated date
                _filteredPhotos
                    .sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

                final photo = _filteredPhotos[index];
                String formattedDate =
                    DateFormat('dd MMM yyyy').format(photo.lastUpdated);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoDetailScreen(photo: photo),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          photo.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                        // Semi-transparent overlay to make text more readable, especially at the bottom
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.black.withOpacity(
                                    0.0), // Fades to transparent towards the top
                              ],
                              stops: const [
                                0.0,
                                0.5
                              ], // Adjust stops for desired fade
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.0,
                          right: 10.0,
                          left: 10,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.blue,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    formattedDate.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                photo.state + ' , ' + photo.country,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Icons.share_outlined,
                                    color: Colors.white,
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
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
