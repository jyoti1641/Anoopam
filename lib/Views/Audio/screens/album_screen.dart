// anoopam_mission/lib/Views/Audio/screens/album_screen.dart
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/category_item.dart';
import 'package:anoopam_mission/Views/Audio/screens/category_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late Future<Map<String, dynamic>> _audioHomeDataFuture;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

 void _onCategoryTap(CategoryItem category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _audioHomeDataFuture = _apiService.fetchAudioHomeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _audioHomeDataFuture = _apiService.fetchAudioHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 17),
                  decoration: InputDecoration(
                    hintText: 'audio.searchBarHint'.tr(),
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150)),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      // _searchQuery = value;
                    });
                  },
                )
              : Text(
                  'audio.albumTitle'.tr(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    // _searchQuery = ''; // Clear search query
                    _searchController.clear(); // Clear text field
                  }
                  _isSearching = !_isSearching; // Toggle search mode
                });
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _audioHomeDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'audio.errorLoadingData'.tr(args: ['${snapshot.error!}']),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: Text('audio.retry'.tr()),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data available.'));
            }

            final data = snapshot.data!;
            final latestAudio = data['latest'] as List<AlbumModel>;
            final featuredAudio = data['featured'] as List<AlbumModel>;
            final categories = data['categories'] as List<CategoryItem>;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Latest Audio Section
                _buildAlbumSection('menu.latestAudio'.tr(), latestAudio),
                const SizedBox(height: 24),
                // Featured Audio Section
                _buildAlbumSection('audio.featuredAudio'.tr(), featuredAudio),
                const SizedBox(height: 24),
                // Categories Section
                _buildCategorySection(categories),
              ],
            );
          },
        ),
      ),
    );
  }
Widget _buildAlbumSection(String title, List<AlbumModel> albums) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 155, // Adjust the height as needed
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: albums.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Displays one row
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.2, // Creates a square aspect ratio
          ),
          itemBuilder: (context, index) {
            final album = albums[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlbumDetailScreen(album: album),
                  ),
                );
              },
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          album.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Icon(Icons.album,
                                  size: 60,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // const SizedBox(height: 4),
                          // Text(
                          //   album.artist ?? 'Unknown Artist',
                          //   style: TextStyle(
                          //     color: Theme.of(context)
                          //         .colorScheme
                          //         .onSurface
                          //         .withAlpha(150),
                          //     fontSize: 14,
                          //   ),
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                        ],
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
  );
}


  Widget _buildCategorySection(List<CategoryItem> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'audio.AudioCategories'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
           padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () => _onCategoryTap(category),
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                clipBehavior: Clip.antiAlias, // This will clip the image to the card's shape
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Stack(
                  fit: StackFit.expand, // This makes the children expand to fill the stack
                  children: [
                    Image.network(
                      category.cover_image,
                      fit: BoxFit.cover, // Ensure the image covers the entire area
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.category,
                            size: 50,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                    // If you want to add the text back, you can use an Align or Positioned widget
                    // to place it on top of the image.
                    // Align(
                    //   alignment: Alignment.bottomLeft,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Text(
                    //       category.title,
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 10,
                    //         color: Colors.white, // Use a contrasting color
                    //       ),
                    //       maxLines: 1,
                    //       overflow: TextOverflow.ellipsis,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
