// anoopam_mission/lib/Views/Audio/screens/album_screen.dart
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_detail_screen.dart';
import 'package:flutter/material.dart';

import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart'; // This is ApiService
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late Future<List<AlbumModel>> _albumsFuture;
  late Future<List<Playlist>> _playlistsFuture;
  final PlaylistService _playlistService = PlaylistService();

  // State variables for search functionality
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: 'Search songs...', // Changed hint text
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : const Text('Album'), // Original title
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
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
                          Text('Error loading albums: ${snapshot.error!}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshAllData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No albums found. Pull down to refresh or check your connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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
                          'No songs found matching "${_searchQuery}".',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
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
                              color: Colors.white,
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
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.album,
                                                size: 60, color: Colors.grey),
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
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          album.artist,
                                          style: TextStyle(
                                            color: Colors.grey[600],
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
                    'My Playlist',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () {
                      _createNewPlaylist();
                    },
                    child: Text(
                      'View All',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16)),
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
                            left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.grey, width: 1),
                        ),
                        color: Colors.white,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 40.0, horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_box_outlined,
                                  size: 30, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Create New Playlist',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to organize your songs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

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
                      itemCount: displayPlaylists.length,
                      itemBuilder: (context, index) {
                        final playlist = displayPlaylists[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetailScreen(
                                    playlist: playlist,
                                    onPlaylistUpdated: _refreshAllData),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: playlist.songs.isNotEmpty
                                        ? Image.network(
                                            playlist.songs.first.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(Icons.queue_music,
                                                  size: 60,
                                                  color: Colors.blueGrey[400]);
                                            },
                                          )
                                        : Icon(Icons.queue_music,
                                            size: 60,
                                            color: Colors.blueGrey[400]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playlist.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${playlist.songs.length} songs',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
