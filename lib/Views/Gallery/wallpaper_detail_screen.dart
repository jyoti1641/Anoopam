// lib/screens/wallpaper_details_screen.dart

import 'package:anoopam_mission/data/photo_service.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/models/wallpaper_models.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'photo_detail_screen.dart';

class WallpaperDetailsScreen extends StatefulWidget {
  final int albumId;
  final String albumTitle;

  const WallpaperDetailsScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
  });

  @override
  State<WallpaperDetailsScreen> createState() => _WallpaperDetailsScreenState();
}

class _WallpaperDetailsScreenState extends State<WallpaperDetailsScreen> {
  WallpaperDetails? _details;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await PhotoApiService.getWallpaperDetails(widget.albumId);
      if (!mounted) return;
      setState(() {
        _details = details;
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(widget.albumTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _details == null || _details!.mobileImages.isEmpty
                  ? const Center(child: Text('No mobile wallpapers found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _details!.mobileImages.length,
                      itemBuilder: (context, index) {
                        final imageUrl = _details!.mobileImages[index];
                        return GestureDetector(
                          onTap: () {
                            final tempPhoto = Photo(
                              id: index,
                              albumId: widget.albumId,
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
                                          size: 40, color: Colors.grey)),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
