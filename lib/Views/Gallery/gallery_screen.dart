// lib/screens/gallery_screen.dart

import 'package:anoopam_mission/Views/Gallery/gallery_wallpapers_screen.dart';
import 'package:anoopam_mission/Views/Gallery/sahebji_darshan_screen.dart';
import 'package:anoopam_mission/Views/Gallery/sahebji_gallery_screen.dart';
import 'package:anoopam_mission/Views/Gallery/thakorji_darshan_screen.dart';
import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/album.dart';
import 'package:anoopam_mission/widgets/album_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

import 'photo_grid_screen.dart';
// You will need to create these new screens

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = false;
  String? _errorMessage;
  final PhotoRepository _repository = PhotoRepository();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
    _searchController.addListener(_filterAlbums);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAlbums);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlbums() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Manually create the list of special albums without specific IDs
    final List<Album> specialAlbums = [
      Album(
        id: 0,
        name: 'Thakorji Darshan',
        thumbnailUrl: 'assets/images/thakorji_darshan_thumbnail.png',
      ),
      Album(
        id: 0,
        name: 'Sahebji Darshan',
        thumbnailUrl: 'assets/images/sahebji_darshan_thumbnail.png',
      ),
      Album(
        id: 0,
        name: 'Sahebji Gallery',
        thumbnailUrl: 'assets/images/sahebji_gallery_thumbnail.png',
      ),
      Album(
        id: 0,
        name: 'Wallpaper',
        thumbnailUrl: 'assets/images/wallpaper_thumbnail.png',
      ),
    ];

    try {
      final fetchedAlbums = await _repository.getAlbums();
      if (!mounted) return;
      setState(() {
        // Filter out any API albums that have the same name as the special ones
        final filteredApiAlbums = fetchedAlbums.where((album) =>
            album.name != 'Thakorji Darshan' &&
            album.name != 'Wallpaper' &&
            album.name != 'Sahebji Darshan' &&
            album.name != 'Sahebji Gallery');

        // Combine the local special albums with the filtered API albums
        _albums = [...specialAlbums, ...filteredApiAlbums];
        _filteredAlbums = _albums;
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

  void _filterAlbums() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAlbums = _albums.where((album) {
        return album.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onAlbumTap(Album album) {
    switch (album.name) {
      case 'Thakorji Darshan':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ThakorjiDarshanScreen()),
        );
        break;
      case 'Sahebji Darshan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SahebjiDarshanScreen()),
        );
        break;
      case 'Sahebji Gallery':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SahebjiGalleryScreen()),
        );
        break;
      case 'Wallpaper':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const GalleryWallpapersScreen()),
        );
        break;
      default:
        // For all other dynamic albums
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoGridScreen(
              albumId: album.id,
              albumName: album.name,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        title: Text('gallery.title'.tr()),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 1,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: InputDecoration(
          //       hintText: 'gallery.searchAlbums'.tr(),
          //       prefixIcon: const Icon(Icons.search),
          //       suffixIcon: _searchController.text.isNotEmpty
          //           ? IconButton(
          //               icon: const Icon(Icons.clear),
          //               onPressed: () {
          //                 _searchController.clear();
          //                 _filterAlbums();
          //               },
          //             )
          //           : null,
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(8.0),
          //         borderSide: BorderSide.none,
          //       ),
          //       filled: true,
          //       fillColor: Colors.grey[200],
          //       contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          //     ),
          //   ),
          // ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
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
                                itemCount: _filteredAlbums.length,
                                itemBuilder: (context, index) {
                                  final album = _filteredAlbums[index];
                                  final themeProvider =
                                      Provider.of<ThemeProvider>(context);
                                  final isDark = themeProvider.currentTheme ==
                                      ThemeMode.dark;
                                  bool isLocalAsset =
                                      album.name == 'Thakorji Darshan' ||
                                          album.name == 'Sahebji Darshan' ||
                                          album.name == 'Sahebji Gallery';
                                  return GestureDetector(
                                    onTap: () => _onAlbumTap(album),
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
                                            isLocalAsset
                                                ? Image.asset(
                                                    album.thumbnailUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Center(
                                                            child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 50,
                                                                color: Colors
                                                                    .grey)),
                                                  )
                                                : Image.network(
                                                    album.thumbnailUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                          color: Colors.grey),
                                                    ),
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    },
                                                  ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black
                                                        .withOpacity(0.6),
                                                  ],
                                                ),
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
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  album.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    shadows: [
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
