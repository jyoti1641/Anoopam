// lib/Views/Audio/widgets/song_list_new.dart

import 'dart:io';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/models/album.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';

// Import necessary models and services
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';

class SongList extends StatefulWidget {
  final List<AudioModel> songs;
  final bool showActionButtons;
  final bool showAlbumArt;
  final String albumCoverUrl;
  final PlaylistService playlistService;
  final VoidCallback? onFavoritesUpdated;
  final Function(int)? onSongTap;

  const SongList({
    super.key,
    required this.songs,
    this.showActionButtons = true,
    required this.albumCoverUrl,
    this.showAlbumArt = true,
    required this.playlistService,
    this.onFavoritesUpdated,
    this.onSongTap,
  });

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  final AlbumServiceNew _audioService = AlbumServiceNew.instance;
  String? _currentPlayingSongUrl;
  _PlayerProcessingState _playerProcessingState = _PlayerProcessingState.idle;
  bool _isPlaying = false;

  List<bool> _isLoadingByIndex = [];

  @override
  void initState() {
    super.initState();
    _audioService.audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _playerProcessingState =
              _mapProcessingState(playerState.processingState);
          _isPlaying = playerState.playing;

          if (_playerProcessingState == _PlayerProcessingState.loading ||
              _playerProcessingState == _PlayerProcessingState.buffering) {
            _initializeLoadingStatusAsAllFalse();
            final currentAudioSource =
                _audioService.audioPlayer.sequenceState?.currentSource;
            if (currentAudioSource != null &&
                currentAudioSource is UriAudioSource) {
              final currentSongUri = currentAudioSource.uri.toString();
              final index = widget.songs
                  .indexWhere((song) => song.audioUrl == currentSongUri);
              if (index != -1) {
                _isLoadingByIndex[index] = true;
              }
            }
          } else {
            _initializeLoadingStatusAsAllFalse();
          }
        });
      }
    });

    _audioService.audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (mounted) {
        setState(() {
          final source = sequenceState?.currentSource;
          if (source is UriAudioSource) {
            _currentPlayingSongUrl = source.uri.toString();
          } else {
            _currentPlayingSongUrl = null;
          }
        });
      }
    });

    _initializeStates();
  }

  _PlayerProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return _PlayerProcessingState.idle;
      case ProcessingState.loading:
        return _PlayerProcessingState.loading;
      case ProcessingState.buffering:
        return _PlayerProcessingState.buffering;
      case ProcessingState.ready:
        return _PlayerProcessingState.ready;
      case ProcessingState.completed:
        return _PlayerProcessingState.completed;
      default:
        return _PlayerProcessingState.idle;
    }
  }

  void _initializeStates() {
    _initializeLoadingStatusAsAllFalse();
  }

  void _initializeLoadingStatusAsAllFalse() {
    if (mounted) {
      setState(() {
        _isLoadingByIndex = List<bool>.filled(widget.songs.length, false);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SongList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songs.length != oldWidget.songs.length ||
        !_areSongListsEqual(widget.songs, oldWidget.songs)) {
      _initializeStates();
    }
  }

  bool _areSongListsEqual(List<AudioModel> list1, List<AudioModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].audioUrl != list2[i].audioUrl) {
        return false;
      }
    }
    return true;
  }

  void _playPauseSong(AudioModel song, int tappedIndex) async {
    if (_currentPlayingSongUrl != song.audioUrl) {
      setState(() {
        _initializeLoadingStatusAsAllFalse();
        _isLoadingByIndex[tappedIndex] = true;
      });
      await _audioService.play(song);
    } else {
      if (_isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.resume();
      }
    }
    widget.onSongTap?.call(tappedIndex);
  }

  // Updated _toggleFavorite method to accept album cover URL
  Future<void> _toggleFavorite(AudioModel song, String albumCoverUrl) async {
    try {
      // Pass the albumCoverUrl to the PlaylistService method
      await widget.playlistService.toggleFavoriteSong(song, albumCoverUrl);
      _showSnackBar('Favorite status updated for ${song.title}');
      widget.onFavoritesUpdated?.call();
    } catch (e) {
      _showSnackBar('Failed to update favorite status: $e');
    }
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
        'Check out this song from Anoopam Mission: ${song.title}\n\n${song.audioUrl}');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _addSongToPlaylist(AudioModel song, String coverimage) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: [song],
          playlistService: widget.playlistService,
          onPlaylistsUpdated: widget.onFavoritesUpdated,
          albumCoverUrl: coverimage,
        ),
      ),
    ).then((_) {
      // No need to call _initializeFavoriteStatus()
    });
  }

  // Updated _showOptionsBottomSheet method
  void _showOptionsBottomSheet(
      BuildContext context, AudioModel song, int index, AlbumModel album) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<bool>(
          future: widget.playlistService.isSongFavorite(song),
          builder: (context, snapshot) {
            bool isFavorite = snapshot.data ?? false;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          song.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Download'),
                      onTap: () {
                        Navigator.pop(context);
                        _downloadSong(song);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.playlist_add),
                      title: const Text('Add to Playlist'),
                      onTap: () {
                        Navigator.pop(context);
                        _addSongToPlaylist(song, widget.albumCoverUrl);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      title: Text(isFavorite ? 'Unlike' : 'Like'),
                      onTap: () async {
                        Navigator.pop(context);
                        // The album cover is available via widget.albumCoverUrl
                        await _toggleFavorite(song, widget.albumCoverUrl);
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.songs.length,
      itemBuilder: (context, index) {
        final song = widget.songs[index];
        AlbumModel album = AlbumModel(
            coverImage: '',
            id: 0,
            title: 'new',
            artist: '',
            albumDate: '',
            albumDuration: '',
            songs: []);

        return Container(
          key: ValueKey(song.audioUrl),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
            onTap: () => _playPauseSong(song, index),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(child: Text(song.artist ?? '')),
                const Text(' : '),
                Text(song.audioDuration ?? ''),
              ],
            ),
            trailing: widget.showActionButtons
                ? GestureDetector(
                    onTap: () {
                      _showOptionsBottomSheet(context, song, index, album);
                    },
                    child: Icon(Icons.more_vert),
                  )
                : null,
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 1,
          color: Colors.grey.shade300,
          indent: 20,
          endIndent: 22,
        );
      },
    );
  }
}

enum _PlayerProcessingState { idle, loading, buffering, ready, completed }
