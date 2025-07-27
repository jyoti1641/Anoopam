// anoopam_mission/lib/Views/Audio/screens/album_screen.dart
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/category_item.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/widgets/content_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart'; // This is ApiService
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late Future<List<CategoryItem>> _mainCategoriesFuture;
  late Future<List<AlbumModel>> _albumsFuture;
  late List<String> recentlyPlayedIds;
  late Future<List<Playlist>> _playlistsFuture;
  final PlaylistService _playlistService = PlaylistService();

  // State variables for search functionality
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();

    _fetchData();
    _mainCategoriesFuture = _apiService.fetchMainCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(CategoryItem category) {
    // Implement navigation or action when a category card is tapped.
    // For example, navigate to a new screen displaying audio items for this category.
    print('Tapped on category: ${category.catName}');
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryAudioListScreen(category: category)));
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _albumsFuture = ApiService().fetchAlbums();

      _playlistsFuture =
          _playlistService.loadPlaylists().then((allPlaylists) async {
        final favoritesPlaylist =
            await _playlistService.getOrCreateFavoritesPlaylist();
        // Ensure favoritesPlaylist is in the list, if not already
        if (!allPlaylists
            .any((p) => p.name == PlaylistService.favoritesPlaylistName)) {
          allPlaylists.add(favoritesPlaylist);
        }
        // Sort playlists to ensure "Favorites" is first, then by name
        allPlaylists.sort((a, b) {
          if (a.name == PlaylistService.favoritesPlaylistName) return -1;
          if (b.name == PlaylistService.favoritesPlaylistName) return 1;
          return a.name.compareTo(b.name);
        });
        return allPlaylists;
      });
    });
    if (mounted) {
      recentlyPlayedIds = await AlbumServiceNew.instance.loadRecentlyPlayed();
      print(recentlyPlayedIds);
    }
  }

  Future<void> _refreshAllData() async {
    await _fetchData();
  }

  // Function to navigate to PlaylistManagerPage to create a new playlist
  void _createNewPlaylist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: null, // Pass null as we are creating a new empty playlist
          playlistService: _playlistService,
          onPlaylistsUpdated:
              _refreshAllData, // Refresh albums and playlists after creation
        ),
      ),
    ).then((_) {
      // Refresh data when returning from PlaylistManagerPage
      _refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
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
                            .withValues(alpha: 0.6)),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
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
                    _searchQuery = ''; // Clear search query
                    _searchController.clear(); // Clear text field
                  }
                  _isSearching = !_isSearching; // Toggle search mode
                });
              },
            ),
            const SizedBox(
                width: 10), // Add some spacing next to the search icon
          ],
        ),
        body: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            FutureBuilder<List<AlbumModel>>(
              future: _albumsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'audio.errorLoadingAlbums'
                                  .tr(args: ['${snapshot.error!}']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 16)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshAllData,
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
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'audio.noAlbumsFound'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 16),
                      ),
                    ),
                  );
                }

                // If in search mode, filter songs; otherwise, display albums
                if (_isSearching && _searchQuery.isNotEmpty) {
                  List<AudioModel> allSongs = [];
                  for (var album in snapshot.data!) {
                    allSongs.addAll(album.songs);
                  }

                  List<AudioModel> filteredSongs = allSongs
                      .where((song) => song.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredSongs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'audio.noSongsFound'.tr(args: [_searchQuery]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // Display filtered songs using SongListNew widget
                  return SongList(
                    songs: filteredSongs,
                    playlistService: PlaylistService(),
                  );
                } else {
                  // Original album display logic when not searching or search query is empty
                  List<AlbumModel> filteredAlbums = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredAlbums.length,
                        itemBuilder: (context, index) {
                          final album = filteredAlbums[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumDetailScreen(
                                    album: album,
                                  ),
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
                                        album.albumArt,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          album.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          album.artist,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const Divider(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'audio.myPlaylist'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _createNewPlaylist();
                    },
                    child: Text(
                      'audio.viewAll'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.indigo,
                      ),
                    ),
                  )
                ],
              ),
            ),
            // User Playlists Section
            FutureBuilder<List<Playlist>>(
              future: _playlistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading playlists: ${snapshot.error!}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 16)),
                    ),
                  );
                }
                final displayPlaylists = snapshot.data!
                    .where((p) =>
                        !(p.name == PlaylistService.favoritesPlaylistName &&
                            p.songs.isEmpty))
                    .toList();

                if (displayPlaylists.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _createNewPlaylist,
                      child: Card(
                        margin: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 5.0, bottom: 5.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(60.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_box_outlined,
                                  size: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.6)),
                              // SizedBox(height: 16),
                              // Text(
                              //   'audio.createNewPlaylist'.tr(),
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.w500,
                              //     color: Colors.indigo,
                              //   ),
                              //   textAlign: TextAlign.center,
                              // ),
                              // SizedBox(height: 8),
                              // Text(
                              //   'audio.tapToOrganize'.tr(),
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     color: Theme.of(context)
                              //         .colorScheme
                              //         .onSurfaceVariant,
                              //   ),
                              //   textAlign: TextAlign.center,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 170, // Fixed height to prevent overflow
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: displayPlaylists.length +
                              1, // +1 for the add tile
                          itemBuilder: (context, index) {
                            // Calculate responsive width with better scaling
                            double screenWidth =
                                MediaQuery.of(context).size.width;
                            double tileWidth = screenWidth * 0.46;

                            // Ensure minimum and maximum width constraints
                            tileWidth = tileWidth.clamp(140.0, 180.0);

                            // If it's the last item (add tile)
                            if (index == displayPlaylists.length) {
                              return SizedBox(
                                width: tileWidth,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: _createNewPlaylist,
                                    child: Card(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withValues(alpha: 0.4),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      elevation: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.2),
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 32,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            // const SizedBox(height: 12),
                                            // Flexible(
                                            //   child: Text(
                                            //     'audio.createNewPlaylist'.tr(),
                                            //     style: TextStyle(
                                            //       fontSize: 13,
                                            //       fontWeight: FontWeight.w600,
                                            //       color: Theme.of(context)
                                            //           .colorScheme
                                            //           .primary,
                                            //     ),
                                            //     textAlign: TextAlign.center,
                                            //     maxLines: 2,
                                            //     overflow: TextOverflow.ellipsis,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Regular playlist tiles
                            final playlist = displayPlaylists[index];
                            return SizedBox(
                              width: tileWidth,
                              height: 180, // Fixed height to prevent overflow
                              child: Container(
                                margin: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlaylistDetailScreen(
                                                playlist: playlist,
                                                onPlaylistUpdated:
                                                    _refreshAllData),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    elevation: 3,
                                    child: Stack(
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Playlist image with fixed height
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16.0),
                                            topRight: Radius.circular(16.0),
                                          ),
                                          child: SizedBox(
                                            height: 180, // Fixed image height
                                            width: double.infinity,
                                            child: playlist.songs.isNotEmpty
                                                ? Image.network(
                                                    playlist
                                                        .songs.first.imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHighest,
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.queue_music,
                                                            size: 36,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.queue_music,
                                                        size: 36,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // Spacing between image and text
                                        const SizedBox(height: 6),
                                        // Playlist title and song count with Flexible wrapper
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: tileWidth * 0.9,
                                              height: 50,
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        playlist.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${playlist.songs.length} songs',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                                alpha: 0.6),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const Divider(),
            ),
            const SizedBox(height: 16),
            // Featured Audio
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'audio.featuredAudio'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _createNewPlaylist();
                    },
                    child: Text(
                      'audio.viewAll'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.indigo,
                      ),
                    ),
                  )
                ],
              ),
            ),
            FutureBuilder<List<AlbumModel>>(
              future: _albumsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'audio.errorLoadingAlbums'
                                  .tr(args: ['${snapshot.error!}']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 16)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshAllData,
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
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'audio.noAlbumsFound'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 16),
                      ),
                    ),
                  );
                }

                // If in search mode, filter songs; otherwise, display albums
                if (_isSearching && _searchQuery.isNotEmpty) {
                  List<AudioModel> allSongs = [];
                  for (var album in snapshot.data!) {
                    allSongs.addAll(album.songs);
                  }

                  List<AudioModel> filteredSongs = allSongs
                      .where((song) => song.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredSongs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'audio.noSongsFound'.tr(args: [_searchQuery]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // Display filtered songs using SongListNew widget
                  return SongList(
                    songs: filteredSongs,
                    playlistService: PlaylistService(),
                  );
                } else {
                  // Original album display logic when not searching or search query is empty
                  List<AlbumModel> filteredAlbums = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredAlbums.length,
                        itemBuilder: (context, index) {
                          final album = filteredAlbums[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumDetailScreen(
                                    album: album,
                                  ),
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
                                        album.albumArt,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          album.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          album.artist,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            // Recently Played
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const Divider(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'audio.RecentlyPlayed'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // _createNewPlaylist();
                    },
                    child: Text(
                      'audio.viewAll'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.indigo,
                      ),
                    ),
                  )
                ],
              ),
            ),
            FutureBuilder<List<AlbumModel>>(
              future: _albumsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'audio.errorLoadingAlbums'
                                  .tr(args: ['${snapshot.error!}']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 16)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshAllData,
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
                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty ||
                    recentlyPlayedIds.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Center(
                      child: Text(
                        'audio.noAlbumsFound'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 16),
                      ),
                    ),
                  );
                }

                // If in search mode, filter songs; otherwise, display albums
                if (_isSearching && _searchQuery.isNotEmpty) {
                  List<AudioModel> allSongs = [];
                  for (var album in snapshot.data!) {
                    allSongs.addAll(album.songs);
                  }

                  List<AudioModel> filteredSongs = allSongs
                      .where((song) => song.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredSongs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'audio.noSongsFound'.tr(args: [_searchQuery]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // Display filtered songs using SongListNew widget
                  return SongList(
                    songs: filteredSongs,
                    playlistService: PlaylistService(),
                  );
                } else {
                  // Original album display logic when not searching or search query is empty
                  List<AlbumModel> filteredAlbums = recentlyPlayedIds
                      .map((id) =>
                          snapshot.data!.firstWhere((album) => album.id == id))
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredAlbums.length,
                        itemBuilder: (context, index) {
                          final album = filteredAlbums[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumDetailScreen(
                                    album: album,
                                  ),
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
                                        album.albumArt,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          album.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          album.artist,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'audio.AudioCategories'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<CategoryItem>>(
              future: _mainCategoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: Failed to Fetch the Data, Make Sure You Have Stable Internet Connection and Try Again by Restarting the App! ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No main categories found.'));
                } else {
                  final List<CategoryItem> mainCategories = snapshot.data!;
                  final displayCategories = mainCategories.take(16).toList();

                  return GridView.builder(
                    shrinkWrap:
                        true, // Important for GridView inside Column/ListView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.8, // Adjust as needed for image
                    ),
                    itemCount: displayCategories.length,
                    itemBuilder: (context, index) {
                      final category = displayCategories[index];
                      return CategoryCard(
                        imageUrl: category.catImage,
                        onTap: () => _onCategoryTap(category),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
