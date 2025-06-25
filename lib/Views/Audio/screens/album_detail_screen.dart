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
        const SnackBar(content: Text('No songs to play.')),
      );
      return;
    }

    // Call your actual audio player service to start playing the list.
    // This assumes AlbumServiceNew.instance.startPlaylist(songs) would internally
    // trigger playback in AudioServiceNew. For navigation, we directly go to the player.
    AlbumServiceNew.instance.startPlaylist(songs); // Use your AlbumServiceNew

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting playback for "${widget.album.title}".')),
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
                        color: Colors.grey[300],
                        child: const Icon(Icons.album,
                            size: 50, color: Colors.grey),
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
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.album.artist,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
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
            title: const Text('Add to a Playlist'), // Changed text for clarity
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              _addSongsToPlaylist(songs);
              // Implement add to playlist logic here (e.g., show another dialog to select playlist)
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //       content: Text(
              //           'Please select a playlist to add songs from "${widget.album.title}" (Placeholder)')),
              // );
              // Example: Assuming PlaylistService has a method to add multiple songs
              // PlaylistService().addSongsToPlaylist(songs);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Album'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              // Actual share logic using share_plus
              var text =
                  'Check out the album "${widget.album.title}" by ${widget.album.artist}!\n\n';
              for (var song in songs) {
                // Iterate through the songs list passed to the bottom sheet
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black, fontSize: 17),
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
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
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
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
            return const Center(child: Text('No songs found in this album.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No songs found in this album.'));
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
                  'No songs found matching "${_searchQuery}".',
                  style: const TextStyle(color: Colors.grey),
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
                          color: Colors.grey[300],
                          child: const Icon(Icons.album,
                              size: 150, color: Colors.grey),
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
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
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
                            color: Theme.of(context).primaryColor,
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
