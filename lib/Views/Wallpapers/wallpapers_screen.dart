import 'package:anoopam_mission/Views/Gallery/wallpaper_detail_screen.dart';
import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/wallpaper_models.dart';
import 'package:anoopam_mission/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class WallpapersScreen extends StatefulWidget {
  const WallpapersScreen({super.key});

  @override
  State<WallpapersScreen> createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends State<WallpapersScreen> {
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
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(25),
              ),
              child: DropdownButtonHideUnderline(
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SvgPicture.asset(
                        'assets/icons/search_blue.svg',
                        color: Colors.blue, // Use Colors.blue for visibility
                        height: 16,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(maxHeight: 16),
                    hintText: 'Year',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    isExpanded: true,
                    icon: const SizedBox.shrink(), // Hiding the default icon
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
                        child: Text(
                          year,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
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
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _albums.length,
                            itemBuilder: (context, index) {
                              final album = _albums[index];
                              final themeProvider =
                                  Provider.of<ThemeProvider>(context);
                              final isDark =
                                  themeProvider.currentTheme == ThemeMode.dark;
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
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.6),
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
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
