import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/album.dart';
import 'package:anoopam_mission/widgets/album_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

import 'photo_grid_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = []; // New list to hold filtered albums
  bool _isLoading = false;
  String? _errorMessage;
  final PhotoRepository _repository =
      PhotoRepository(); // Instantiate repository
  TextEditingController _searchController =
      TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
    // Add a listener to the search controller to filter albums as the user types
    _searchController.addListener(_filterAlbums);
  }

  @override
  void dispose() {
    _searchController.removeListener(
        _filterAlbums); // Remove listener to prevent memory leaks
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _fetchAlbums() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedAlbums = await _repository.getAlbums();
      if (!mounted) return;
      setState(() {
        _albums = fetchedAlbums;
        _filteredAlbums = fetchedAlbums;
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

  // Method to filter albums based on search query
  void _filterAlbums() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAlbums = _albums.where((album) {
        return album.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('gallery.title'.tr()),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 1,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Column(
        // Use Column for vertical arrangement in the body
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0), // Padding for the search bar
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'gallery.searchAlbums'.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear(); // Clear search text
                          _filterAlbums(); // Trigger filter to show all albums
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(
            // Expanded to allow GridView to take remaining space
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: [38;5;9m$_errorMessage[0m'))
                    : _filteredAlbums.isEmpty &&
                            _searchController.text.isNotEmpty
                        ? const Center(child: Text('No matching albums found.'))
                        : _albums.isEmpty
                            ? const Center(child: Text('No albums found.'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                physics: const BouncingScrollPhysics(),
                                itemCount: _filteredAlbums
                                    .length, // Use filteredAlbums here
                                itemBuilder: (context, index) {
                                  final album = _filteredAlbums[index];
                                  final themeProvider =
                                      Provider.of<ThemeProvider>(context);
                                  final isDark = themeProvider.currentTheme ==
                                      ThemeMode.dark;
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PhotoGridScreen(
                                            albumId: album.id,
                                            albumName: album.name,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withOpacity(0.5)
                                                : Colors.grey.withOpacity(0.18),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Album image
                                            Image.network(
                                              album.thumbnailUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                            ),
                                            // Text overlay at bottom
                                            Positioned(
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.45),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(12),
                                                    bottomRight:
                                                        Radius.circular(12),
                                                  ),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    album.name,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      shadows: const [
                                                        Shadow(
                                                          blurRadius: 3.0,
                                                          color: Colors.black,
                                                          offset:
                                                              Offset(1.0, 1.0),
                                                        ),
                                                      ],
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
