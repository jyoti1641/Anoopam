// lib/Views/Audio/services/playlist_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';

class PlaylistService {
  static const _playlistsKey = 'user_playlists';
  // New key to store favorite song URLs
  static const _favoritesKey = 'user_favorites';

  Future<List<Playlist>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playlistsJson = prefs.getString(_playlistsKey);
    if (playlistsJson == null) {
      return [];
    }
    try {
      final List<dynamic> jsonList = json.decode(playlistsJson);
      return jsonList
          .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error decoding playlists from SharedPreferences: $e');
      return [];
    }
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        playlists.map((playlist) => playlist.toJson()).toList();
    await prefs.setString(_playlistsKey, json.encode(jsonList));
  }

  Future<void> createPlaylist(String playlistName) async {
    List<Playlist> playlists = await loadPlaylists();
    if (!playlists.any((p) => p.name == playlistName)) {
      playlists
          .add(Playlist(name: playlistName, songs: [], coverImageUrl: null));
      await savePlaylists(playlists);
    }
  }

  Future<void> addSongToPlaylist(
      String playlistName, AudioModel song, String albumCoverUrl) async {
    List<Playlist> playlists = await loadPlaylists();
    Playlist? targetPlaylist;

    try {
      targetPlaylist = playlists.firstWhere((p) => p.name == playlistName);
    } catch (e) {
      targetPlaylist = Playlist(name: playlistName, songs: []);
      playlists.add(targetPlaylist);
    }

    if (!targetPlaylist.songs.any((s) => s.audioUrl == song.audioUrl)) {
      targetPlaylist.songs.add(song);
      if (targetPlaylist.coverImageUrl == null ||
          targetPlaylist.coverImageUrl!.isEmpty) {
        targetPlaylist.coverImageUrl = albumCoverUrl;
      }
    }
    await savePlaylists(playlists);
  }

  // NEW METHOD to add multiple songs to a playlist
  Future<void> addSongsToPlaylist(String playlistName,
      List<AudioModel> songsToAdd, String albumCoverUrl) async {
    List<Playlist> playlists = await loadPlaylists();
    Playlist? targetPlaylist;

    try {
      targetPlaylist = playlists.firstWhere((p) => p.name == playlistName);
    } catch (e) {
      targetPlaylist = Playlist(name: playlistName, songs: []);
      playlists.add(targetPlaylist);
    }

    // Add each song from the list, avoiding duplicates
    for (var song in songsToAdd) {
      if (!targetPlaylist.songs.any((s) => s.audioUrl == song.audioUrl)) {
        targetPlaylist.songs.add(song);
      }
    }

    // Set the cover image if the playlist previously had none
    if (targetPlaylist.coverImageUrl == null ||
        targetPlaylist.coverImageUrl!.isEmpty) {
      targetPlaylist.coverImageUrl = albumCoverUrl;
    }

    await savePlaylists(playlists);
  }

  Future<Playlist> getFavorites() async {
    final List<String> favoriteUrls = await _loadFavorites();
    // In a real app, you would fetch the full AudioModel objects from a
    // database or API based on the URLs. For this example, we create dummy
    // AudioModels. You might need to adjust this part based on your data source.
    final List<AudioModel> favoriteSongs = favoriteUrls
        .map((url) => AudioModel(
              audioUrl: url,
              title: 'Favorite Song', // Placeholder
              artist: 'Unknown Artist', // Placeholder
              audioDuration: '0:00', // Placeholder
              id: 0,
            ))
        .toList();

    // Now get the real data for favorite songs by checking albums

    return Playlist(
      name: 'Favorites',
      songs: favoriteSongs,
      coverImageUrl: null,
    );
  }

  Future<void> removeSongFromPlaylist(
      String playlistName, AudioModel songToRemove) async {
    List<Playlist> playlists = await loadPlaylists();
    for (var playlist in playlists) {
      if (playlist.name == playlistName) {
        playlist.songs
            .removeWhere((song) => song.audioUrl == songToRemove.audioUrl);
        if (playlist.songs.isEmpty) {
          playlist.coverImageUrl = null;
        }
        break;
      }
    }
    await savePlaylists(playlists);
  }

  Future<void> deletePlaylist(String playlistName) async {
    List<Playlist> playlists = await loadPlaylists();
    playlists.removeWhere((playlist) => playlist.name == playlistName);
    await savePlaylists(playlists);
  }

  // New method to load favorite song URLs
  Future<List<String>> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList(_favoritesKey);
    return favorites ?? [];
  }

  // New method to save favorite song URLs
  Future<void> _saveFavorites(List<String> favoriteUrls) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteUrls);
  }

  // Method to toggle a song's favorite status
  Future<void> toggleFavoriteSong(AudioModel song) async {
    List<String> favoriteUrls = await _loadFavorites();
    final String audioUrl = song.audioUrl;

    if (favoriteUrls.contains(audioUrl)) {
      favoriteUrls.remove(audioUrl);
    } else {
      favoriteUrls.add(audioUrl);
    }

    await _saveFavorites(favoriteUrls);
  }

  // Method to check if a song is a favorite
  Future<bool> isSongFavorite(AudioModel song) async {
    List<String> favoriteUrls = await _loadFavorites();
    return favoriteUrls.contains(song.audioUrl);
  }
}
