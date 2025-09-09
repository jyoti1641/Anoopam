// lib/Views/Audio/screens/favourites_page.dart

import 'dart:io';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final PlaylistService _playlistService = PlaylistService();
  List<AudioModel> _favoriteSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteSongs();
  }

  Future<void> _loadFavoriteSongs() async {
    setState(() {
      _isLoading = true;
    });
    final favorites = await _playlistService.loadFavorites();
    setState(() {
      _favoriteSongs = favorites;
      _isLoading = false;
    });
  }

  // Method to remove a song from favorites
  Future<void> _removeFromFavorites(AudioModel song) async {
    try {
      // The toggleFavoriteSong method in PlaylistService is now updated to handle the album cover URL.
      // We pass null for the albumCoverUrl here because we are removing the song.
      await _playlistService.toggleFavoriteSong(song, '');
      _showSnackBar('Removed "${song.title}" from favorites.');
      await _loadFavoriteSongs(); // Reload the list to update the UI
    } catch (e) {
      _showSnackBar('Failed to remove song: $e');
    }
  }

  void _playAllSongs(BuildContext context, List<AudioModel> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No songs to play.')),
      );
      return;
    }
    AlbumServiceNew.instance.startPlaylist(songs);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(songs: songs, initialIndex: 0),
      ),
    );
  }

  Future<void> _downloadSong(AudioModel song) async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      _showSnackBar('Storage permission is required to download files.');
      return;
    }
    _showSnackBar('Downloading ${song.title}...');
    try {
      final Directory? publicDirectory = await getExternalStorageDirectory();
      if (publicDirectory == null) {
        _showSnackBar('Could not find a valid downloads directory.');
        return;
      }
      final Directory appDownloadsDirectory =
          Directory('${publicDirectory.path}/Anoopam Mission Audio');
      if (!await appDownloadsDirectory.exists()) {
        await appDownloadsDirectory.create(recursive: true);
      }
      final fileName =
          '${song.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}.mp3';
      final filePath = '${appDownloadsDirectory.path}/$fileName';
      final response = await http.get(Uri.parse(song.audioUrl));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        _showSnackBar(
            '"${song.title}" downloaded to: ${appDownloadsDirectory.path}');
      } else {
        _showSnackBar('Failed to download "${song.title}".');
      }
    } catch (e) {
      _showSnackBar('Error downloading "${song.title}": $e');
    }
  }

  void _shareSong(AudioModel song) {
    Share.share(
        'Check out this song: ${song.title} by ${song.artist}. Listen here: ${song.audioUrl}');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showOptionsBottomSheet(BuildContext context, AudioModel song) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadSong(song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from Favorites'),
              onTap: () {
                Navigator.pop(context);
                _removeFromFavorites(song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareSong(song);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFavoriteSongs,
              child: _favoriteSongs.isEmpty
                  ? const Center(
                      child: Text('No liked audios found.'),
                    )
                  : ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Liked Audios',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text('${_favoriteSongs.length} tracks'),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {
                                      // Logic to download all favorite songs
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill,
                                        color: Colors.indigo, size: 40),
                                    onPressed: () =>
                                        _playAllSongs(context, _favoriteSongs),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _favoriteSongs.length,
                          itemBuilder: (context, index) {
                            final song = _favoriteSongs[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: song.albumCoverUrl != null &&
                                        song.albumCoverUrl!.isNotEmpty
                                    ? Image.network(
                                        song.albumCoverUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.music_note,
                                                    size: 50),
                                      )
                                    : const Icon(Icons.music_note, size: 50),
                              ),
                              title: Text(song.title),
                              subtitle: Text(
                                  '${song.artist ?? 'Unknown Artist'} | ${song.audioDuration}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () =>
                                    _showOptionsBottomSheet(context, song),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
    );
  }
}
