// lib/Views/Audio/screens/my_library_screen.dart

import 'package:anoopam_mission/Views/Audio/models/recently_played_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  final PlaylistService _playlistService = PlaylistService();
  // This service is correctly separated and handles the song data.

  late Future<int> _downloadCountFuture;
  late Future<List<Playlist>> _playlistsFuture;
  late Future<List<AudioModel>> _favoritesFuture;
  // This future is now correctly typed to fetch songs, not albums.
  late Future<List<RecentlyPlayedSongModel>> _recentlyPlayedFuture;

  Future<void> _fetchData() async {
    setState(() {
      _downloadCountFuture = _playlistService.getDownloadedSongsCount();
      _playlistsFuture = _playlistService.loadPlaylists();
      _favoritesFuture = _playlistService.loadFavorites();
      // This is the key change: calling the correct service method.
      _recentlyPlayedFuture = _playlistService.getRecentlyPlayed();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('audio.myLibraryTitle'.tr()),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCountsSection(),
                const SizedBox(height: 24),
                // Correctly calls the method that builds the songs list
                _buildRecentlyPlayedSection(),
                const SizedBox(height: 24),
                // _buildPlaylistsSection(),
                // const SizedBox(height: 24),
                // _buildFavoritesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FutureBuilder<List<Playlist>>(
          future: _playlistsFuture,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return _buildCountCard(
                'audio.playlists'.tr(), Icons.playlist_play_rounded, count, () {
              // TODO: Navigate to Playlists list screen
            });
          },
        ),
        FutureBuilder<List<AudioModel>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return _buildCountCard(
                'audio.favorites'.tr(), Icons.favorite_rounded, count, () {
              // TODO: Navigate to Favorites list screen
            });
          },
        ),
        FutureBuilder<int>(
          future: _downloadCountFuture,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _buildCountCard('audio.downloads'.tr(),
                Icons.download_for_offline_rounded, count, () {
              // TODO: Navigate to Downloads list screen
            });
          },
        ),
      ],
    );
  }

  Widget _buildCountCard(
      String title, IconData icon, int count, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Icon(icon,
                    size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedSection() {
    // This part is now correctly building a list of songs, not albums.
    return FutureBuilder<List<RecentlyPlayedSongModel>>(
      future: _recentlyPlayedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final songs = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'audio.recentlyPlayedTitle'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      song.albumCoverUrl ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.music_note,
                              size: 30, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Flexible(
                        child: Text(song.artist ?? 'Unknown Artist',
                            style: TextStyle(fontSize: 12)),
                      ),
                      const Text(' | '),
                      song.audioDuration != null
                          ? Text(song.audioDuration!,
                              style: TextStyle(fontSize: 12))
                          : const SizedBox.shrink(),
                    ],
                  ),
                  trailing: Icon(Icons.more_vert_outlined),
                  onTap: () {
                    // This is where you would handle playing the song.
                    // You would need to navigate to the AudioPlayerScreen with the song details.
                    // A simple approach is to get the full song details from the API using its ID.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Playing "${song.title}"...')),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Widget _buildPlaylistsSection() {
  //   return FutureBuilder<List<Playlist>>(
  //     future: _playlistsFuture,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       }
  //       final playlists = snapshot.data ?? [];
  //       if (playlists.isEmpty) {
  //         return const SizedBox.shrink();
  //       }
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'audio.myPlaylists'.tr(),
  //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //           ),
  //           const SizedBox(height: 16),
  //           ListView.builder(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: playlists.length,
  //             itemBuilder: (context, index) {
  //               final playlist = playlists[index];
  //               return ListTile(
  //                 leading: ClipRRect(
  //                   borderRadius: BorderRadius.circular(8.0),
  //                   child: playlist.coverImageUrl != null
  //                       ? Image.network(
  //                           playlist.coverImageUrl!,
  //                           width: 50,
  //                           height: 50,
  //                           fit: BoxFit.cover,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             return Container(
  //                               width: 50,
  //                               height: 50,
  //                               color: Colors.grey[300],
  //                               child: const Icon(Icons.audiotrack,
  //                                   size: 30, color: Colors.grey),
  //                             );
  //                           },
  //                         )
  //                       : Container(
  //                           width: 50,
  //                           height: 50,
  //                           color: Colors.grey[300],
  //                           child: const Icon(Icons.audiotrack,
  //                               size: 30, color: Colors.grey),
  //                         ),
  //                 ),
  //                 title: Text(playlist.name),
  //                 subtitle:
  //                     Text('${playlist.songs.length} ${'audio.songs'.tr()}'),
  //                 trailing: const Icon(Icons.chevron_right),
  //                 onTap: () async {
  //                   await Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => PlaylistDetailScreen(
  //                         playlist: playlist,
  //                         onPlaylistUpdated: _fetchData,
  //                       ),
  //                     ),
  //                   );
  //                   _fetchData();
  //                 },
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildFavoritesSection() {
  //   return FutureBuilder<List<AudioModel>>(
  //     future: _favoritesFuture,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       }
  //       final favorites = snapshot.data ?? [];
  //       if (favorites.isEmpty) {
  //         return const SizedBox.shrink();
  //       }
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'audio.myFavorites'.tr(),
  //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //           ),
  //           const SizedBox(height: 16),
  //           const SizedBox(height: 100),
  //         ],
  //       );
  //     },
  //   );
  // }
}
