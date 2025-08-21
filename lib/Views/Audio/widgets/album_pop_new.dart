// anoopam_mission/lib/Views/Audio/screens/album_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;

  final GlobalKey _songListKey = GlobalKey();
  final PlaylistService _playlistService = PlaylistService();
  final ApiService _apiService = ApiService(); // Instantiate ApiService

  AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    album.coverImage,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.album, size: 80, color: Colors.grey),
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
                        album.title,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        album.artist ?? '',
                        style: TextStyle(
                          fontSize: 18.0,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Songs in this Album',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<AlbumModel>(
              // Use the new fetchAlbumDetails method to get the full album data
              future: _apiService.fetchAlbumDetails(album.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.songs!.isEmpty) {
                  return const Center(child: Text('No songs found in this album.'));
                }

                // Pass the songs list from the fetched full album to the SongList widget
                return SongList(
                  key: _songListKey,
                  songs: snapshot.data!.songs!,
                  showActionButtons: true,
                  showAlbumArt: true,
                  playlistService: _playlistService,
                  onFavoritesUpdated: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}