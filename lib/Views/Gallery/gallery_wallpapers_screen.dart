// lib/screens/wallpapers_screen.dart

import 'package:anoopam_mission/Views/Gallery/wallpaper_detail_screen.dart';
import 'package:anoopam_mission/data/photo_service.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/models/wallpaper_models.dart';

class GalleryWallpapersScreen extends StatefulWidget {
  const GalleryWallpapersScreen({super.key});

  @override
  State<GalleryWallpapersScreen> createState() =>
      _GalleryWallpapersScreenState();
}

class _GalleryWallpapersScreenState extends State<GalleryWallpapersScreen> {
  List<WallpaperAlbum> _albums = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedYear;

  List<String> get yearsList {
    int currentYear = DateTime.now().year;
    return List<String>.generate(
      10,
      (index) => (currentYear - index).toString(),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year.toString();
    _fetchWallpapers();
  }

  Future<void> _fetchWallpapers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedAlbums =
          await PhotoApiService.getWallpapers(year: _selectedYear);
      if (!mounted) return;
      setState(() {
        _albums = fetchedAlbums;
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
      appBar: AppBar(
        title: const Text('Wallpapers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedYear,
                  hint: const Text('Years'),
                  isExpanded: true,
                  icon: const Icon(Icons.search),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                      _fetchWallpapers();
                    }
                  },
                  items: yearsList.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _albums.isEmpty
                        ? const Center(
                            child: Text('No wallpapers found for this year.'))
                        : GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: _albums.length,
                            itemBuilder: (context, index) {
                              final album = _albums[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WallpaperDetailsScreen(
                                        albumId: album.id,
                                        albumTitle: album.title,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        album.wallpaperUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Center(
                                                child: Icon(Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.grey)),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          color: Colors.black54,
                                          child: Text(
                                            album.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 3.0,
                                                    color: Colors.black,
                                                    offset: Offset(1.0, 1.0))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
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
