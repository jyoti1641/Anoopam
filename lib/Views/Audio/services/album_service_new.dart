// lib/Views/Audio/services/audio_service_new.dart
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_dtx/shared_preferences_dtx.dart'; // Import the just_audio package

class AlbumServiceNew {
  // Singleton pattern for easy access
  static final AlbumServiceNew _instance = AlbumServiceNew._internal();

  factory AlbumServiceNew() {
    return _instance;
  }

  AlbumServiceNew._internal() {
    _audioPlayer = AudioPlayer(); // Initialize the audio player
    // Optional: Listen to player state changes or other streams if needed for UI updates
    // _audioPlayer.playerStateStream.listen((state) {
    //   debugPrint('Player State: ${state.processingState}, Playing: ${state.playing}');
    // });
  }

  static AlbumServiceNew get instance => _instance;

  late AudioPlayer _audioPlayer; // The actual audio player instance

  // Getter for the audio player instance if other parts of the app need direct access
  AudioPlayer get audioPlayer => _audioPlayer;

  // This method will handle playing a list of songs as a playlist
  Future<void> startPlaylist(List<AudioModel> songs) async {
    if (songs.isEmpty) {
      debugPrint('No songs provided to start playlist.');
      await _audioPlayer.stop(); // Stop any current playback if list is empty
      return;
    }

    try {
      // Create an AudioSource for each song in the playlist
      final audioSources = songs
          .map((song) => AudioSource.uri(Uri.parse(song.songUrl)))
          .toList();

      // Create a ConcatenatingAudioSource to play songs one after another
      final playlist = ConcatenatingAudioSource(children: audioSources);

      // Set the audio source for the player
      await _audioPlayer.setAudioSource(playlist);

      // Start playing the first song in the playlist
      await _audioPlayer.play();

      debugPrint(
          'AlbumServiceNew: Started playlist with ${songs.length} songs.');
      debugPrint('Now playing: ${songs.first.title}');
    } catch (e) {
      debugPrint('Error starting playlist: $e');
      // You might want to show a user-friendly error message here
    }
  }

  // Method to play a single song
  Future<void> play(AudioModel song) async {
    try {
      await _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(song.songUrl)));
      await _audioPlayer.play();
      debugPrint('AlbumServiceNew: Now playing single song: ${song.title}');
    } catch (e) {
      debugPrint('Error playing single song: $e');
    }
  }

  // Method to pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    debugPrint('AlbumServiceNew: Playback paused.');
  }

  // Method to resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
    debugPrint('AlbumServiceNew: Playback resumed.');
  }

  // Method to stop playback and release resources
  Future<void> stop() async {
    await _audioPlayer.stop();
    debugPrint('AlbumServiceNew: Playback stopped.');
  }

  // Method to skip to the next song in the playlist
  Future<void> skipToNext() async {
    await _audioPlayer.seekToNext();
    debugPrint('AlbumServiceNew: Skipped to next song.');
  }

  // Method to skip to the previous song in the playlist
  Future<void> skipToPrevious() async {
    await _audioPlayer.seekToPrevious();
    debugPrint('AlbumServiceNew: Skipped to previous song.');
  }

  // Stream to listen to changes in the player's state (e.g., playing, paused, loading)
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // Stream to listen to changes in the current playback position
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;

  // Stream to listen to the total duration of the current media
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // Dispose the player when it's no longer needed (e.g., when the app closes)
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    debugPrint('AlbumServiceNew: Player disposed.');
  }

  static const _recentlyPlayedKey = 'recently_played';
  Future<List<String>> loadRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_recentlyPlayedKey)) {
      return prefs.getStringListOrElse(_recentlyPlayedKey, defaultValue: []);
    } else {
      await prefs.setStringList(_recentlyPlayedKey, []);
      return prefs.getStringListOrElse(_recentlyPlayedKey, defaultValue: []);
    }
  }

  Future<bool> setRecentAlbum(AlbumModel album) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadRecentlyPlayed();

    final filteredList = list.where((l) => l != album.id).toList();
    await prefs.setStringList(_recentlyPlayedKey, [album.id, ...filteredList]);
    return true;
  }
}
