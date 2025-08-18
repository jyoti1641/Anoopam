// lib/Views/Audio/widgets/song_list_new.dart (Updated to use AlbumServiceNew)
import 'dart:io';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart'; // Import just_audio for ProcessingState enum

// Import necessary models and services (assuming these are in their respective paths)
import 'package:anoopam_mission/Views/Audio/models/playlist.dart'; // You will need to provide this.
import 'package:anoopam_mission/Views/Audio/models/song.dart'; // AudioModel (your AudioModel)
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart'; // Your PlaylistService
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart'; // Your AlbumServiceNew (which uses just_audio)
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart'; // Your PlaylistManagerPage (if it exists)

class SongList extends StatefulWidget {
  final List<AudioModel> songs;
  final bool showActionButtons;
  final bool showAlbumArt;
  final PlaylistService playlistService;
  final VoidCallback? onFavoritesUpdated;
  final Function(int)? onSongTap; // Added for navigation to AudioPlayerScreen

  const SongList({
    super.key,
    required this.songs,
    this.showActionButtons = true,
    this.showAlbumArt = true,
    required this.playlistService,
    this.onFavoritesUpdated,
    this.onSongTap, // Initialize new parameter
  });

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  // Now correctly references AlbumServiceNew as the primary audio service.
  final AlbumServiceNew _audioService = AlbumServiceNew.instance;

  // Track the currently playing song URL from AlbumServiceNew
  String? _currentPlayingSongUrl;

  // Track player state from AlbumServiceNew
  _PlayerProcessingState _playerProcessingState = _PlayerProcessingState.idle;
  bool _isPlaying = false; // Directly track if the player is currently playing

  List<bool> _isFavoriteByIndex = [];
  List<bool> _isLoadingByIndex = [];

  @override
  void initState() {
    super.initState();
    // Listen to changes from the centralized AlbumServiceNew
    _audioService.audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _playerProcessingState =
              _mapProcessingState(playerState.processingState);
          _isPlaying = playerState.playing;

          // If the player is loading or buffering, show loading indicator
          if (_playerProcessingState == _PlayerProcessingState.loading ||
              _playerProcessingState == _PlayerProcessingState.buffering) {
            _initializeLoadingStatusAsAllFalse(); // Clear previous loading states
            // Find the index of the currently playing song to show loading.
            final currentAudioSource =
                _audioService.audioPlayer.sequenceState?.currentSource;
            if (currentAudioSource != null &&
                currentAudioSource is UriAudioSource) {
              final currentSongUri = currentAudioSource.uri.toString();
              final index = widget.songs
                  .indexWhere((song) => song.songUrl == currentSongUri);
              if (index != -1) {
                _isLoadingByIndex[index] = true;
              }
            }
          } else {
            // Once not loading/buffering, ensure no loading indicators are shown
            _initializeLoadingStatusAsAllFalse();
          }
        });
      }
    });

    _audioService.audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (mounted) {
        setState(() {
          // Update _currentPlayingSongUrl based on the audio service's state
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

  // Helper to map just_audio's ProcessingState to our internal enum (optional, but good for clarity)
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
    _initializeFavoriteStatus();
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
    // No need to dispose _audioPlayer here as it's managed by AlbumServiceNew
    super.dispose();
  }

  void _initializeFavoriteStatus() async {
    final favSongList =
        await widget.playlistService.getOrCreateFavoritesPlaylist();
    final songUrls = favSongList.songs.map((s) => s.songUrl).toSet();

    if (mounted) {
      setState(() {
        _isFavoriteByIndex =
            widget.songs.map((s) => songUrls.contains(s.songUrl)).toList();
      });
    }
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
      if (list1[i].songUrl != list2[i].songUrl) {
        return false;
      }
    }
    return true;
  }

  // Modified to use AlbumServiceNew for playback methods
  void _playPauseSong(AudioModel song, int tappedIndex) async {
    if (_currentPlayingSongUrl != song.songUrl) {
      // If a different song is tapped, stop current and play new one via service
      setState(() {
        _initializeLoadingStatusAsAllFalse();
        _isLoadingByIndex[tappedIndex] = true; // Show loading for the new song
      });
      // Corrected: Calling .play(song) method of AlbumServiceNew
      await _audioService.play(song);
      // The _currentPlayingSongUrl and _isPlaying will be updated by the service's streams
    } else {
      // Same song tapped, toggle play/pause via service
      if (_isPlaying) {
        // Use _isPlaying which is driven by AlbumServiceNew's state
        await _audioService.pause();
      } else {
        await _audioService.resume();
      }
    }
    // Call the onSongTap callback for AlbumDetailScreen to navigate
    widget.onSongTap?.call(tappedIndex);
  }

  void _toggleFavorite(AudioModel song, int tappedIndex) async {
    if (tappedIndex < 0 || tappedIndex >= _isFavoriteByIndex.length) {
      _showSnackBar('Error: Invalid song index.');
      return;
    }

    setState(() {
      _isFavoriteByIndex[tappedIndex] = !_isFavoriteByIndex[tappedIndex];
      if (_isFavoriteByIndex[tappedIndex]) {
        _showSnackBar('${song.title} added to favorites!');
      } else {
        _showSnackBar('${song.title} removed from favorites.');
      }
    });

    try {
      await widget.playlistService.toggleFavoriteSong(song);
      widget.onFavoritesUpdated?.call();
    } catch (e) {
      setState(() {
        _isFavoriteByIndex[tappedIndex] = !_isFavoriteByIndex[tappedIndex];
      });
      _showSnackBar('Failed to update favorite status: $e');
    }
  }

  Future<void> _downloadSong(AudioModel song) async {
    _showSnackBar('Downloading ${song.title}...');
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${song.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}.mp3';
      final filePath = '${directory.path}/$fileName';

      final response = await http.get(Uri.parse(song.songUrl));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        _showSnackBar('${song.title} downloaded to ${directory.path}');
      } else {
        _showSnackBar(
            'Failed to download ${song.title}. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error downloading ${song.title}: $e');
    }
  }

  void _shareSong(AudioModel song) {
    Share.share(
        'Check out this song from Anoopam Mission: ${song.title}\n\n${song.songUrl}');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
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
        ),
      ),
    ).then((_) {
      _initializeFavoriteStatus();
    });
  }

  // MODIFIED FUNCTION FOR THE BOTTOM SHEET
  void _showOptionsBottomSheet(
      BuildContext context, AudioModel song, int index) {
    final isFavorite = _isFavoriteByIndex[index];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                    _addSongToPlaylist(song);
                  },
                ),
                ListTile(
                  leading: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  title: Text(isFavorite ? 'Unlike' : 'Like'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleFavorite(song, index);
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
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.songs.length,
      itemBuilder: (context, index) {
        final song = widget.songs[index];
        final isCurrentlySelected = _currentPlayingSongUrl == song.songUrl;
        // _isPlaying now comes from AlbumServiceNew's actual playback state
        final isPlayingThisSong = isCurrentlySelected && _isPlaying;
        final isLoadingThisSong =
            _isLoadingByIndex.isNotEmpty && _isLoadingByIndex[index];

        return Container(
          key: ValueKey(song.songUrl), // Use ValueKey for better performance
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
            onTap: () =>
                _playPauseSong(song, index), // This will also navigate now
            // leading: Stack(
            //   alignment: Alignment.center,
            //   children: [
            //     if (widget.showAlbumArt) SizedBox.shrink(),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(4.0),
            //   child: Image.network(
            //     song.imageUrl,
            //     width: 50,
            //     height: 50,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) {
            //       return Container(
            //         width: 50,
            //         height: 50,
            //         color: Colors.grey[300],
            //         child: const Icon(Icons.music_note,
            //             size: 30, color: Colors.grey),
            //       );
            //     },
            //   ),
            // ),
            // Show loading indicator only for the currently loading song
            //     if (isLoadingThisSong)
            //       Container(
            //         width: 50,
            //         height: 50,
            //         decoration: BoxDecoration(
            //           color: Colors.black45,
            //           borderRadius: BorderRadius.circular(4.0),
            //         ),
            //         child: const Center(
            //           child: SizedBox(
            //             width: 24,
            //             height: 24,
            //             child: CircularProgressIndicator(
            //               strokeWidth: 2,
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       )
            //     // Show pause icon only if this specific song is playing
            //     else if (isPlayingThisSong)
            //       Container(
            //         width: 50,
            //         height: 50,
            //         decoration: BoxDecoration(
            //           color: Colors.black45,
            //           borderRadius: BorderRadius.circular(4.0),
            //         ),
            //         child: const Icon(
            //           Icons.pause,
            //           color: Colors.white,
            //           size: 30,
            //         ),
            //       ),
            //   ],
            // ),
            title: Text(
              song.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(song.artist), // Added subtitle for artist
            trailing: widget.showActionButtons
                ? IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showOptionsBottomSheet(context, song, index);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}

// Internal enum to mirror just_audio's ProcessingState for clarity in _SongListState
enum _PlayerProcessingState { idle, loading, buffering, ready, completed }