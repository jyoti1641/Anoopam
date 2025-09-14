// lib/Views/Audio/screens/my_library_screen.dart

import 'dart:io';

import 'package:anoopam_mission/Views/Audio/models/recently_played_model.dart';
import 'package:anoopam_mission/Views/Audio/screens/create_new_playlist_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/downloaded_file_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/favorite_songs_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:anoopam_mission/Views/Audio/screens/recently_played_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  final PlaylistService _playlistService = PlaylistService();
  // This service is correctly separated and handles the song data.
  bool _isCountGridView = false;
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

  void _showSongOptionsBottomSheet(RecentlyPlayedSongModel song) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        // Create a temporary AudioModel from the stored data
        final tempAudioModel = AudioModel(
          id: song.id!,
          title: song.title,
          audioUrl: song.audioUrl, // Audio URL is now available
          artist: song.artist,
          audioDuration: song.audioDuration,
          albumCoverUrl: song.albumCoverUrl,
        );

        return FutureBuilder<bool>(
          future: _playlistService.isSongFavorite(tempAudioModel),
          builder: (context, snapshot) {
            bool isFavorite = snapshot.data ?? false;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      song.albumCoverUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.album,
                              size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(song.artist ?? 'Unknown Artist',
                      style: const TextStyle(fontSize: 14)),
                ),
                const Divider(height: 1),
                Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/download_blue.svg',
                        height: 18,
                      ),
                      title: const Text('Download'),
                      onTap: () async {
                        Navigator.pop(context);
                        _downloadSong(tempAudioModel);
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/circular_plus.svg',
                        height: 18,
                      ),
                      title: const Text('Add to Playlist'),
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistManagerPage(
                              songsToAdd: [tempAudioModel],
                              playlistService: _playlistService,
                              onPlaylistsUpdated: _fetchData,
                              albumCoverUrl: song.albumCoverUrl,
                            ),
                          ),
                        );
                        _fetchData();
                      },
                    ),
                    ListTile(
                      leading: isFavorite
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : SvgPicture.asset(
                              'assets/icons/like.svg',
                              height: 18,
                            ),
                      title: Text(isFavorite ? 'Unlike' : 'Like'),
                      onTap: () async {
                        Navigator.pop(context);
                        _toggleFavorite(tempAudioModel);
                      },
                    ),
                    //  const SizedBox(width: 10),
                    ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/search_blue.svg',
                        height: 18,
                      ),
                      title: const Text('Share'),
                      onTap: () {
                        Navigator.pop(context);
                        Share.share('Check out this song: ${song.title}');
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Download functionality
  void _downloadSong(AudioModel song) async {
    try {
      // No permission request is needed here because the PlaylistService
      // correctly uses getExternalStorageDirectory(), which saves files to
      // an app-specific directory.
      await PlaylistService().downloadAndSaveSong(song);
      _showSnackBar('"${song.title}" downloaded.');
    } catch (e) {
      _showSnackBar('Error downloading "${song.title}": $e');
    }
  }

  // Favorite functionality
  Future<void> _toggleFavorite(AudioModel song) async {
    try {
      await _playlistService.toggleFavoriteSong(song, song.albumCoverUrl ?? '');
      _showSnackBar('Favorite status updated for ${song.title}');
      _fetchData(); // Refresh favorites count
    } catch (e) {
      _showSnackBar('Failed to update favorite status: $e');
    }
  }

  // New method for the "Create New Playlist" bottom sheet
  void _showCreateNewPlaylistBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () async {
            Navigator.pop(context); // Close the bottom sheet

            // Navigate to the CreateNewPlaylistScreen
            String? newPlaylistName = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateNewPlaylistScreen(),
              ),
            );

            // Handle the returned playlist name
            if (newPlaylistName != null && newPlaylistName.isNotEmpty) {
              if ((await _playlistsFuture)
                  .any((p) => p.name == newPlaylistName)) {
                _showSnackBar('Playlist "$newPlaylistName" already exists.');
                return;
              }
              try {
                await _playlistService.createPlaylist(newPlaylistName);
                _showSnackBar(
                    'Playlist "$newPlaylistName" created successfully.');
                _fetchData(); // Refresh the playlist data
              } catch (e) {
                _showSnackBar('Error creating playlist: $e');
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                SizedBox(width: 15),
                SvgPicture.asset(
                  'assets/icons/music.svg',
                  height: 18,
                ),
                SizedBox(width: 25),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Playlist',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build a playlist',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // This is a placeholder for the rest of your UI
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('audio.myLibraryTitle'.tr()),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SvgPicture.asset(
            'assets/icons/back.svg',
            height: 16,
          ),
        ),
        actions: [
          GestureDetector(
            child: SvgPicture.asset(
              'assets/icons/search_blue.svg',
              height: 18,
            ),
            onTap: () {},
          ),
          const SizedBox(width: 10),
          GestureDetector(
            child: SvgPicture.asset(
              'assets/icons/circular_plus.svg',
              height: 18,
            ),
            onTap: _showCreateNewPlaylistBottomSheet,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          _downloadCountFuture,
          _playlistsFuture,
          _favoritesFuture,
          _recentlyPlayedFuture
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return RefreshIndicator(
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
                    _buildRecentlyPlayedSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCountGridView = !_isCountGridView;
                  });
                },
                child: SvgPicture.asset(
                  _isCountGridView
                      ? 'assets/icons/grid_icon.svg'
                      : 'assets/icons/list_icon.svg',
                  height: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder(
          future: Future.wait(
              [_playlistsFuture, _favoritesFuture, _downloadCountFuture]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            final playlistCount = (snapshot.data?[0] as List?)?.length ?? 0;
            final favoritesCount = (snapshot.data?[1] as List?)?.length ?? 0;
            final downloadsCount = (snapshot.data?[2] as int?) ?? 0;

            final List<Map<String, dynamic>> countData = [
              {
                'title': 'audio.playlists'.tr(),
                'icon': SvgPicture.asset(
                  'assets/icons/playlists.svg',
                  height: 20,
                ),
                'count': playlistCount,
                'subtitle': 'playlists',
                'onTap': () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistManagerPage(
                        // songsToAdd: songs,
                        playlistService: PlaylistService(),
                        onPlaylistsUpdated: () {
                          // Handle the updated playlists
                        },
                        albumCoverUrl: ' ',
                      ),
                    ),
                  );
                }
              },
              {
                'title': 'audio.favorites'.tr(),
                'icon': SvgPicture.asset(
                  'assets/icons/like.svg',
                  height: 18,
                ),
                'count': favoritesCount,
                'subtitle': 'favorites',
                'onTap': () {
                  // Navigate to favorites screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavouritesPage(),
                    ),
                  );
                }
              },
              {
                'title': 'audio.downloads'.tr(),
                'icon': SvgPicture.asset(
                  'assets/icons/download_blue.svg',
                  height: 18,
                ),
                'count': downloadsCount,
                'subtitle': 'downloads',
                'onTap': () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DownloadedFilesScreen(),
                    ),
                  );
                }
              },
            ];

            return _isCountGridView
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: countData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5, // Adjust as needed
                    ),
                    itemBuilder: (context, index) {
                      final item = countData[index];
                      return _buildCountCard(item['title'], item['icon'],
                          item['count'], item['onTap'], item['subtitle']);
                    },
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: countData.length,
                    itemBuilder: (context, index) {
                      final item = countData[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildCountListTile(item['title'], item['icon'],
                            item['count'], item['onTap']),
                      );
                    },
                  );
          },
        ),
      ],
    );
  }

  Widget _buildCountCard(String title, Widget icon, int count,
      VoidCallback onTap, String subtitle) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // color: Theme.of(context).colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString() + ' ' + subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountListTile(
      String title, Widget icon, int count, VoidCallback onTap) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outline)),
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        '${count.toString()} items',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      onTap: onTap,
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
                'audio.RecentlyPlayed'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 2.0),
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
                  trailing: GestureDetector(
                    onTap: () {
                      _showSongOptionsBottomSheet(song);
                    },
                    child: Icon(Icons.more_vert_outlined),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecentlyPlayedAudioPlayer(
                          songs: songs,
                          initialIndex: index,
                        ),
                      ),
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
