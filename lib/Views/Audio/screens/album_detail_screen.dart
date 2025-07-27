// lib/Views/Audio/screens/album_detail_screen.dart (Modified for consolidated AudioPlayerScreen and Search)
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
// Import the single consolidated file that contains AudioPlayerScreen and all its dependencies.
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart'; // This is AlbumServiceNew
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';

class AlbumDetailScreen extends StatefulWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  // State variables for search functionality
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function for the "Play All" functionality
  void _playAllSongs(BuildContext context, List<AudioModel> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('album.noSongsToPlay'.tr())),
      );
      return;
    }

     

    // Call your actual audio player service to start playing the list.
    // This assumes AlbumServiceNew.instance.startPlaylist(songs) would internally
    // trigger playback in AudioServiceNew. For navigation, we directly go to the player.
    AlbumServiceNew.instance.startPlaylist(songs); // Use your AlbumServiceNew
    AlbumServiceNew.instance.setRecentAlbum(widget.album);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('album.startingPlayback'
              .tr(namedArgs: {'title': widget.album.title}))),
    );

    // Navigate to the new AudioPlayerScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(songs: songs, initialIndex: 0),
      ),
    );
  }

  // Function to show the album menu bottom sheet
  void _showAlbumMenu(BuildContext context, List<AudioModel> songs) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildAlbumBottomSheet(context, songs);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled:
          true, // Allows the bottom sheet to be full screen if content needs it
    );
  }

  // Widget to build the content of the album bottom sheet
  Widget _buildAlbumBottomSheet(BuildContext context, List<AudioModel> songs) {
    void _addSongsToPlaylist(List<AudioModel> songs) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaylistManagerPage(
            songsToAdd: songs,
            playlistService: PlaylistService(),
            // onPlaylistsUpdated: widget.onFavoritesUpdated,
          ),
        ),
      ).then((_) {
        // _initializeFavoriteStatus();
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.album.albumArt,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Icon(Icons.album,
                            size: 50,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.album.title,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.album.artist,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
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
          const Divider(),

          // ListTile(
          //   leading: const Icon(Icons.download),
          //   title: const Text('Download Album'),
          //   onTap: () {
          //     Navigator.pop(context); // Close the bottom sheet
          //     // Implement download logic here
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //           content: Text(
          //               'Downloading album "${widget.album.title}"... (Placeholder)')),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: Text('album.addToPlaylist'.tr()),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              _addSongsToPlaylist(songs);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text('album.share'.tr()),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              var text = 'album.shareText'.tr(namedArgs: {
                'title': widget.album.title,
                'artist': widget.album.artist
              });
              for (var song in songs) {
                text += '\n${song.title}\n${song.songUrl}\n';
              }
              Share.share(text);
            },
          ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                ),
                decoration: InputDecoration(
                  hintText: 'album.searchSongs'.tr(),
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                widget.album.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
        centerTitle: true,
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
          const SizedBox(width: 10), // Add some spacing next to the search icon
        ],
      ),
      body: FutureBuilder<List<AudioModel>>(
        future: ApiService().getSongsByAlbum(widget.album.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('album.noSongsFound'.tr()));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('album.noSongsFound'.tr()));
          }

          List<AudioModel> songs = snapshot.data!;

          // Apply search filter if in searching mode and query is not empty
          if (_isSearching && _searchQuery.isNotEmpty) {
            songs = songs
                .where((song) =>
                    song.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    song.artist
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();
            // If after filtering, no songs are found
            if (songs.isEmpty) {
              return Center(
                child: Text(
                  'album.noSongsMatch'.tr(namedArgs: {'query': _searchQuery}),
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              );
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album Header Layout
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      widget.album.albumArt,
                      width: double.infinity,
                      height: 250, // Adjust height as needed
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Icon(Icons.album,
                              size: 150,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 17),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.album.title,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Action Buttons on the right
                      Row(
                        children: [
                          // Menu Button (opens bottom sheet)
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            iconSize: 28.0,
                            onPressed: () => _showAlbumMenu(context, songs),
                          ),
                          // Play All Button (visible directly on the screen)
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill),
                            color: Colors.indigo,
                            iconSize: 40.0,
                            onPressed: () => _playAllSongs(context, songs),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Song List
                SongList(
                  songs: songs, // Pass the potentially filtered list
                  showActionButtons: true,
                  showAlbumArt: true,
                  playlistService: PlaylistService(),
                  // When a song is tapped in SongList, navigate to AudioPlayerScreen
                  onSongTap: (int tappedIndex) {
                    AlbumServiceNew.instance.setRecentAlbum(widget.album);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayerScreen(
                          songs: songs, // Pass the potentially filtered list
                          initialIndex: tappedIndex,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
