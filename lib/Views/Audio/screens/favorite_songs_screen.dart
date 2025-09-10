// lib/Views/Audio/screens/favourites_page.dart

import 'dart:io';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
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
  final ApiService _apiService = ApiService();
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

  Future<void> _downloadAllFavorites() async {
    if (_favoriteSongs.isEmpty) {
      _showSnackBar('No favorite songs to download.');
      return;
    }

    var status = await Permission.storage.request();
    if (status.isDenied) {
      _showSnackBar('Storage permission is required to download files.');
      return;
    }

    _showSnackBar('Downloading all favorite songs...');

    for (var song in _favoriteSongs) {
      try {
        await _playlistService.downloadAndSaveSong(song);
        _showSnackBar('\"${song.title}\" downloaded.');
      } catch (e) {
        _showSnackBar('Error downloading \"${song.title}\": $e');
      }
    }

    _showSnackBar('All favorite songs finished downloading.');
  }

  void _addSongToPlaylist(AudioModel song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: [song],
          playlistService: _playlistService,
          onPlaylistsUpdated: _loadFavoriteSongs, // Refresh the page on return
          albumCoverUrl: song.albumCoverUrl,
        ),
      ),
    );
  }

  // void _viewAlbum(AudioModel song) async {
  //   try {
  //     debugPrint(
  //         'Album ID: \\${song.albumId}'); // Log the album ID for debugging

  //     if (song.albumId == null) {
  //       _showSnackBar('No album information available for this song.');
  //       return;
  //     }

  //     final albumDetails = await _apiService.fetchAlbumDetails(song.albumId!);

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => AlbumDetailScreen(album: albumDetails),
  //       ),
  //     );
  //   } catch (e) {
  //     _showSnackBar('Error navigating to album: $e');
  //   }
  // }

  void _downloadSong(AudioModel song) async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      _showSnackBar('Storage permission is required.');
      return;
    }
    try {
      await _playlistService.downloadAndSaveSong(song);
      _showSnackBar('"${song.title}" downloaded.');
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      song.albumCoverUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.music_note, size: 24),
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
                          song.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/download_blue.svg',
                height: 18,
              ),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadSong(song);
              },
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/circular_plus.svg',
                height: 18,
              ),
              title: const Text('Add to Other Playlist'),
              onTap: () {
                Navigator.pop(context);
                _addSongToPlaylist(song);
              },
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/like.svg',
                height: 18,
              ),
              title: const Text('Unlike'),
              onTap: () {
                Navigator.pop(context);
                _removeFromFavorites(song);
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.album),
            //   title: const Text('View Album'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _viewAlbum(song);
            //   },
            // ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/share_blue.svg',
                height: 18,
              ),
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
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SvgPicture.asset(
            'assets/icons/back.svg',
            height: 16,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          GestureDetector(
            child: SvgPicture.asset(
              'assets/icons/search_blue.svg',
              height: 18,
            ),
            onTap: () {},
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
                child: SvgPicture.asset(
                  'assets/icons/circular_plus.svg',
                  height: 18,
                ),
                onTap: () {}),
          )
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
                        SizedBox(
                          height: 30,
                        ),
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
                                    icon: SvgPicture.asset(
                                      'assets/icons/download_blue.svg',
                                      height: 18,
                                    ),
                                    onPressed: _downloadAllFavorites,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill,
                                        color: Color(0xff034DA2), size: 40),
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
                                child: const Icon(Icons.more_vert),
                                onTap: () =>
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
