import 'package:anoopam_mission/Views/Gallery/photo_detail_screen.dart';
import 'package:flutter/material.dart';
import 'wallpaper_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:anoopam_mission/widgets/photo_card.dart';

class WallpapersScreen extends StatefulWidget {
  const WallpapersScreen({super.key});

  @override
  State<WallpapersScreen> createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends State<WallpapersScreen> {
  List<Photo> _allPhotos = [];
  List<Photo> _filteredPhotos = [];
  bool _isLoading = false;
  String? _errorMessage;
  final PhotoRepository _repository = PhotoRepository();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPhotosForAlbum();
    _searchController.addListener(_filterPhotos);
  }

  Future<void> _fetchPhotosForAlbum() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedPhotos = await _repository.getwallpaperPhotos();
      setState(() {
        _allPhotos = fetchedPhotos;
        _filteredPhotos = fetchedPhotos;
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

  void _filterPhotos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPhotos = _allPhotos
          .where((photo) =>
              photo.state.toLowerCase().contains(query) ||
              photo.country.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('wallpapers.title'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'wallpapers.searchHint'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : GridView.builder(
                          itemCount: _filteredPhotos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemBuilder: (context, index) {
                            final photo = _filteredPhotos[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PhotoDetailScreen(
                                      photo: photo,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(photo.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  color: Colors.black.withOpacity(0.5),
                                  child: Text(
                                    '${photo.state}, ${photo.country}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
