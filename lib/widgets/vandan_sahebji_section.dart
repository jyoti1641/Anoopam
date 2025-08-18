import 'package:anoopam_mission/Views/Gallery/photo_detail_screen.dart';
import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';

class VandanSahebjiSection extends StatefulWidget {
  const VandanSahebjiSection({super.key});

  @override
  State<VandanSahebjiSection> createState() => _VandanSahebjiSectionState();
}

class _VandanSahebjiSectionState extends State<VandanSahebjiSection> {
  List<Photo> _allPhotos = [];
  List<Photo> _filteredPhotos = [];
  bool _isLoading = false;
  String? _errorMessage;
  final PhotoRepository _repository = PhotoRepository();
  String? _selectedCountry;
  String? _selectedState;
  DateTime? _selectedLastUpdated;
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
      final fetchedPhotos = await _repository.getsahebjiPhotos();
      setState(() {
        _allPhotos = fetchedPhotos;
        _setInitialFilterDisplay();
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Error fetching photos: $e');
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

    String defaultCountry = _allPhotos.first.country;
    String defaultState = _allPhotos.first.state;
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

    DateTime? earliestDate;
    for (var photo in _allPhotos) {
      if (earliestDate == null || photo.lastUpdated.isBefore(earliestDate)) {
        earliestDate = photo.lastUpdated;
      }
    }

    if (earliestDate != null) {
      _currentDateDisplay =
          'Last updated after ${DateFormat('dd MMM yyyy').format(earliestDate)}';
    } else {
      _currentDateDisplay = 'No Date Info';
    }
  }

  void _applyFilters() {
    List<Photo> tempFiltered = List.from(_allPhotos);

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
          .where((photo) => photo.lastUpdated.isAfter(_selectedLastUpdated!))
          .toList();
    }

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
            'After ${DateFormat('dd MMM yyyy').format(_selectedLastUpdated!)}';
      } else {
        _currentDateDisplay = 'All Times';
      }
    } else {
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
    _applyFilters();
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
                image: AssetImage('assets/icons/vandan_sahebji.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text(
                'menu.vandanSahebji'.tr(),
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
            height: MediaQuery.of(context).size.height * 0.37,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.3,
              ),
              itemCount: _filteredPhotos.length,
              itemBuilder: (context, index) {
                final photo = _filteredPhotos[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PhotoDetailScreen(photo: photo),
                            ),
                          );
                        },
                        child: Image.network(
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
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10.0,
                        right: 10.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PhotoDetailScreen(photo: photo),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icons/download.svg',
                            color: Colors.white,
                            height: 16,
                          ),
                        ),
                      ),
                    ],
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
