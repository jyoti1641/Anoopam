// lib/Views/Audio/widgets/playlist_song_list.dart

import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PlaylistSongList extends StatefulWidget {
  final List<AudioModel> songs;
  final PlaylistService playlistService;
  final Playlist playlist;
  final VoidCallback? onFavoritesUpdated;
  final Function(int)? onSongTap;

  const PlaylistSongList({
    super.key,
    required this.songs,
    required this.playlist,
    required this.playlistService,
    this.onFavoritesUpdated,
    this.onSongTap,
  });

  @override
  State<PlaylistSongList> createState() => _PlaylistSongListState();
}

class _PlaylistSongListState extends State<PlaylistSongList> {
  final AlbumServiceNew _audioService = AlbumServiceNew.instance;
  String? _currentPlayingSongUrl;
  bool _isAlbumLoading = false;
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
            if (currentAudioSource is UriAudioSource) {
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
  void didUpdateWidget(covariant PlaylistSongList oldWidget) {
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

  Future<void> _toggleFavorite(AudioModel song, String albumCoverUrl) async {
    try {
      await widget.playlistService.toggleFavoriteSong(song, albumCoverUrl);
      _showSnackBar('Favorite status updated for ${song.title}');
      widget.onFavoritesUpdated?.call();
    } catch (e) {
      _showSnackBar('Failed to update favorite status: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _addSongToPlaylist(AudioModel song) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: [song],
          playlistService: widget.playlistService,
          onPlaylistsUpdated: widget.onFavoritesUpdated,
          albumCoverUrl: song.albumCoverUrl,
        ),
      ),
    );
  }

  Future<void> _removeSongFromPlaylist(AudioModel song) async {
    try {
      // First, remove the song from the service (database/shared preferences)
      await widget.playlistService
          .removeSongFromPlaylist(widget.playlist.name, song);
      _showSnackBar('Removed "${song.title}" from "${widget.playlist.name}"');

      // Now, remove the song from the local list to update the UI
      widget.playlist.songs.removeWhere((s) => s.audioUrl == song.audioUrl);

      // Trigger the parent's refresh method to rebuild the UI
      widget.onFavoritesUpdated?.call();
    } catch (e) {
      _showSnackBar('Failed to remove song from playlist: $e');
    }
  }

  Future<void> _viewAlbum(AudioModel song) async {
    setState(() {
      _isAlbumLoading = true;
    });
    try {
      final album = await ApiService().fetchAlbumDetails(song.albumId!);
      // setState(() {
      //   _isAlbumLoading = false;
      // });
      if (album != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailScreen(album: album),
          ),
        );
      } else {
        _showSnackBar('Failed to find album for this song.');
      }
    } catch (e) {
      setState(() {
        _isAlbumLoading = false;
      });
      _showSnackBar('Error navigating to album: $e');
    } finally {
      setState(() {
        _isAlbumLoading = false;
      });
    }
  }

  Future<void> _downloadSong(AudioModel song) async {
    // Request permission to access storage
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

  void _showOptionsBottomSheet(BuildContext context, AudioModel song) {
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
                  leading: const Icon(Icons.download),
                  title: const Text('Download'),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadSong(song);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('Add to Other Playlist'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSongToPlaylist(song);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline),
                  title: const Text('Remove from this Playlist'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeSongFromPlaylist(song);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.album),
                  title: const Text('View Album'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewAlbum(song);
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
                    await _toggleFavorite(song, song.albumCoverUrl!);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reversedSongs = widget.songs.reversed.toList();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedSongs.length,
      itemBuilder: (context, index) {
        final song = reversedSongs[index];

        return Container(
          key: ValueKey(song.audioUrl),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
            onTap: () => _playPauseSong(song, index),
            leading: ClipRRect(
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
            title: Text(
              song.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(child: Text(song.artist ?? '')),
                const Text(' : '),
                Text(song.audioDuration ?? ''),
              ],
            ),
            trailing: GestureDetector(
              onTap: () {
                _showOptionsBottomSheet(context, song);
              },
              child: const Icon(Icons.more_vert),
            ),
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
