// lib/Views/Audio/screens/playlist_detail_screen.dart
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart'; // Your existing SongList

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback
      onPlaylistUpdated; // Callback to refresh playlists in AlbumScreen

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.onPlaylistUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final PlaylistService _playlistService = PlaylistService();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          playlist.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
          : SongList(
              songs: playlist.songs,
              showActionButtons:
                  true, // You might want to show action buttons for songs within a playlist
              showAlbumArt: true, playlistService: _playlistService,
            ),
    );
  }
}
