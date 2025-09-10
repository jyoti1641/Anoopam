// lib/Views/Audio/screens/downloaded_files_screen.dart

import 'dart:io';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:anoopam_mission/Views/Audio/models/downloaded_song_model.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';

class DownloadedFilesScreen extends StatefulWidget {
  const DownloadedFilesScreen({super.key});

  @override
  State<DownloadedFilesScreen> createState() => _DownloadedFilesScreenState();
}

class _DownloadedFilesScreenState extends State<DownloadedFilesScreen> {
  // final AlbumServiceNew _audioService = AlbumServiceNew.instance;
  late Future<List<DownloadedSongModel>> _downloadedSongsFuture;

  @override
  void initState() {
    super.initState();
    _downloadedSongsFuture = PlaylistService().getDownloadedSongs();
  }

  Future<void> _refreshDownloads() async {
    setState(() {
      _downloadedSongsFuture = PlaylistService().getDownloadedSongs();
    });
  }

  void _playDownloadedSong(DownloadedSongModel song, int initialIndex,
      List<DownloadedSongModel> songs) {
    // We need to convert the local file paths back to a format your AudioPlayerScreen can use.
    // Assuming your AudioPlayerScreen can handle a list of AudioModel, we'll create that list.
    final List<AudioModel> localSongs = songs
        .map((s) => AudioModel(
              id: s.id ?? 0,
              title: s.title,
              audioUrl: s.filePath, // Use the local file path as the audioUrl
              artist: s.artist,
              audioDuration: s.audioDuration,
              albumCoverUrl: s.albumCoverUrl,
            ))
        .toList();

    // Pass the list of local songs to your audio player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AudioPlayerScreen(songs: localSongs, initialIndex: initialIndex),
      ),
    );
  }

  void _playAllSongsLocally(List<DownloadedSongModel> songs) {
    if (songs.isEmpty) {
      _showSnackBar('No songs to play.');
      return;
    }
    _playDownloadedSong(songs.first, 0, songs);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _removeDownloadedSong(DownloadedSongModel song) async {
    await PlaylistService().removeDownloadedSong(song);
    _refreshDownloads();
    _showSnackBar('Removed "${song.title}" from downloads.');
  }

  void _showOptionsBottomSheet(DownloadedSongModel song) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (context) => Column(
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
              'assets/icons/remove.svg',
              height: 18,
            ),
            title: const Text('Remove Download'),
            onTap: () {
              Navigator.pop(context);
              _removeDownloadedSong(song);
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/share_blue.svg',
              height: 18,
            ),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              _showSnackBar(
                  'Sharing functionality not yet implemented for local files.');
              // You can use the share_plus package to share the file, e.g.:
              // Share.shareXFiles([XFile(song.filePath)]);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
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
      body: FutureBuilder<List<DownloadedSongModel>>(
        future: _downloadedSongsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading downloaded files.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No downloaded songs found.'));
          }

          final downloadedSongs = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshDownloads,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Downloaded',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: () => _playAllSongsLocally(downloadedSongs),
                        icon: const Icon(
                          Icons.play_circle,
                          size: 30,
                          color: Color(0xff034DA2),
                        ),
                        label: const Text(
                          'PLAY ALL',
                          style: TextStyle(
                              color: Color(0xff034DA2),
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: downloadedSongs.length,
                  itemBuilder: (context, index) {
                    final song = downloadedSongs[index];
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
                      title: Text(song.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showOptionsBottomSheet(song),
                      ),
                      onTap: () =>
                          _playDownloadedSong(song, index, downloadedSongs),
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
