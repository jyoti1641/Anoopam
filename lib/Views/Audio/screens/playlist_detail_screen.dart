// lib/Views/Audio/screens/playlist_detail_screen.dart
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart'; // Your existing SongList
import 'package:easy_localization/easy_localization.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback
      onPlaylistUpdated; // Callback to refresh playlists in AlbumScreen

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.onPlaylistUpdated,
  });

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('album.startingPlayback'
              .tr(namedArgs: {'title': playlist.name}))),
    );

    // Navigate to the new AudioPlayerScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(songs: songs, initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlaylistService _playlistService = PlaylistService();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          // Optional: Add an option to delete the playlist
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Implement delete playlist logic here
              // You'll need to remove it from shared preferences and call onPlaylistUpdated
              final bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Playlist'),
                    content: Text(
                        'Are you sure you want to delete "${playlist.name}"?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                // Implement playlist deletion using PlaylistService
                // Example: await PlaylistService().deletePlaylist(playlist.name);
                // For now, let's just pop back and refresh
                Navigator.of(context).pop(); // Go back to AlbumScreen
                onPlaylistUpdated(); // Trigger refresh
              }
            },
          ),
        ],
      ),
      body: playlist.songs.isEmpty
          ? Center(
              child: Text(
                'This playlist is empty. Add some songs!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          : ListView(
            children: [
               Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 17),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          playlist.name,
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
                          // Play All Button (visible directly on the screen)
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill),
                            color: Colors.indigo,
                            iconSize: 40.0,
                            onPressed: () => _playAllSongs(context, playlist.songs),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SongList(
              songs: playlist.songs,
              showActionButtons:
                  true, // You might want to show action buttons for songs within a playlist
              showAlbumArt: true, playlistService: _playlistService,
                onSongTap: (int tappedIndex) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayerScreen(
                          songs: playlist.songs, // Pass the potentially filtered list
                          initialIndex: tappedIndex,
                        ),
                      ),
                    );
                  },
            ),
            ]
          ),
    );
  }
}
