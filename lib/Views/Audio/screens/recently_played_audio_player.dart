// lib/Views/Audio/screens/audio_player_screen.dart

import 'package:anoopam_mission/Views/Audio/models/recently_played_model.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';

class RecentlyPlayedAudioPlayer extends StatefulWidget {
  final List<RecentlyPlayedSongModel> songs; // Updated to use the new model
  final int initialIndex;

  const RecentlyPlayedAudioPlayer({
    super.key,
    required this.songs,
    this.initialIndex = 0,
  });

  @override
  State<RecentlyPlayedAudioPlayer> createState() =>
      _RecentlyPlayedAudioPlayerState();
}

class _RecentlyPlayedAudioPlayerState extends State<RecentlyPlayedAudioPlayer> {
  final AlbumServiceNew _audioService = AlbumServiceNew.instance;
  late AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  int _currentSongIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  @override
  void initState() {
    super.initState();
    _audioPlayer = _audioService.audioPlayer;
    _currentSongIndex = widget.initialIndex;
    _setupAudioPlayerListeners();
    _initializePlaylistAndPlay();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Duration _parseDuration(String durationString) {
    if (durationString.isEmpty) return Duration.zero;
    try {
      final parts = durationString.split(':');
      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return Duration(minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      debugPrint('Error parsing duration string "$durationString": $e');
    }
    return Duration.zero;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  MediaItem _createMediaItem(RecentlyPlayedSongModel song) {
    final durationInMilliseconds =
        _parseDuration(song.audioDuration ?? '').inMilliseconds;

    return MediaItem(
      id: song.audioUrl,
      title: song.title,
      artist: song.artist,
      album: song.artist,
      duration: Duration(milliseconds: durationInMilliseconds),
    );
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _isPlaying = playerState.playing;
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position ?? Duration.zero;
        });
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });

    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (mounted) {
        setState(() {
          if (sequenceState != null &&
              sequenceState.currentIndex != _currentSongIndex) {
            _currentSongIndex = sequenceState.currentIndex;
            if (widget.songs.isNotEmpty &&
                _currentSongIndex < widget.songs.length) {
              _totalDuration = _parseDuration(
                  widget.songs[_currentSongIndex].audioDuration ?? '');
            }
          }
        });
      }
    });

    _audioPlayer.loopModeStream.listen((loopMode) {
      if (mounted) {
        setState(() {
          _loopMode = loopMode;
        });
      }
    });

    _audioPlayer.shuffleModeEnabledStream.listen((isEnabled) {
      if (mounted) {
        setState(() {
          _isShuffleEnabled = isEnabled;
        });
      }
    });
  }

  void _initializePlaylistAndPlay() async {
    if (widget.songs.isEmpty) {
      debugPrint('No songs to initialize playlist.');
      return;
    }

    try {
      final audioSources = widget.songs
          .map((song) => AudioSource.uri(
                Uri.parse(song.audioUrl),
                tag: _createMediaItem(song),
              ))
          .toList();

      final playlist = ConcatenatingAudioSource(children: audioSources);

      await _audioPlayer.setAudioSource(playlist,
          initialIndex: widget.initialIndex, initialPosition: Duration.zero);

      _audioPlayer.play();

      if (widget.songs.isNotEmpty &&
          widget.initialIndex < widget.songs.length) {
        setState(() {
          _totalDuration = _parseDuration(
              widget.songs[widget.initialIndex].audioDuration ?? '');
        });
      }
    } catch (e) {
      debugPrint("Error loading audio source: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio: ${e.toString()}')),
      );
    }
  }

  void _togglePlayPause() async {
    if (_audioPlayer.playerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void _skipToNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    } else {
      if (_loopMode == LoopMode.all) {
        await _audioPlayer.seek(Duration.zero, index: 0);
      } else if (_loopMode == LoopMode.off) {
        await _audioPlayer.stop();
      }
    }
  }

  void _skipToPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    } else {
      if (_loopMode == LoopMode.all) {
        await _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.sequence!.length - 1);
      } else if (_loopMode == LoopMode.off) {
        await _audioPlayer.seek(Duration.zero);
      }
    }
  }

  void _toggleShuffle() async {
    await _audioPlayer.setShuffleModeEnabled(!_isShuffleEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shuffle: ${_isShuffleEnabled ? 'On' : 'Off'}')),
    );
  }

  void _toggleRepeat() async {
    LoopMode newMode;
    if (_loopMode == LoopMode.off) {
      newMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      newMode = LoopMode.one;
    } else {
      newMode = LoopMode.off;
    }
    await _audioPlayer.setLoopMode(newMode);

    String message = '';
    if (newMode == LoopMode.off) message = 'Repeat: Off';
    if (newMode == LoopMode.all) message = 'Repeat: All';
    if (newMode == LoopMode.one) message = 'Repeat: One';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _shareSong() {
    final currentSong = widget.songs[_currentSongIndex];
    Share.share(
        'Check out the song "${currentSong.title}" by ${currentSong.artist} on AnoopaMission! ${currentSong.audioUrl}');
  }

  // Helper to determine the correct image provider (network vs. file)
  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if the URL is a local file path
      if (!imageUrl.startsWith('http')) {
        return FileImage(File(imageUrl));
      }
      // It's a network image
      return NetworkImage(imageUrl);
    }
    // Return a fallback image provider
    return const AssetImage('assets/images/default_playlist.png');
  }

  @override
  Widget build(BuildContext context) {
    final currentSong =
        widget.songs.isNotEmpty && _currentSongIndex < widget.songs.length
            ? widget.songs[_currentSongIndex]
            : null;

    final isPlayerLoadingOrBuffering =
        _audioPlayer.playerState.processingState == ProcessingState.loading ||
            _audioPlayer.playerState.processingState ==
                ProcessingState.buffering;

    // Get the correct image provider for the current song
    final ImageProvider? coverImageProvider = currentSong != null
        ? _getImageProvider(currentSong.albumCoverUrl)
        : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: currentSong == null
          ? Center(
              child: Text(
                'No song selected or playlist is empty.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: coverImageProvider != null
                        ? Image(
                            image: coverImageProvider,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.width * 0.9,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Icon(Icons.music_note,
                                    size: 100,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              );
                            },
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Icon(Icons.music_note,
                                size: 100,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currentSong.artist ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          size: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: _shareSong,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.0,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.0),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16.0),
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveTrackColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          thumbColor: Theme.of(context).primaryColor,
                          overlayColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _currentPosition.inSeconds.toDouble(),
                          min: 0.0,
                          max: _totalDuration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffleEnabled
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                          ),
                          iconSize: 28.0,
                          onPressed: _toggleShuffle,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          iconSize: 48.0,
                          onPressed: _skipToPrevious,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: isPlayerLoadingOrBuffering
                            ? const SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 50.0,
                                onPressed: _togglePlayPause,
                              ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.skip_next,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          iconSize: 48.0,
                          onPressed: _skipToNext,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            _loopMode == LoopMode.off
                                ? Icons.repeat
                                : _loopMode == LoopMode.all
                                    ? Icons.repeat_on
                                    : Icons.repeat_one_on,
                            color: _loopMode != LoopMode.off
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                          ),
                          iconSize: 28.0,
                          onPressed: _toggleRepeat,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
    );
  }
}
