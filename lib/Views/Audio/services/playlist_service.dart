// lib/Views/Audio/services/playlist_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:http/http.dart' as http;

class PlaylistService {
  static const _playlistsKey = 'user_playlists';
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

  Future<Playlist?> getPlaylist(String playlistName) async {
    final allPlaylists = await loadPlaylists();
    try {
      return allPlaylists.firstWhere((p) => p.name == playlistName);
    } catch (e) {
      return null;
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
        targetPlaylist.coverImageUrl = song.albumCoverUrl;
      }
    }
    await savePlaylists(playlists);
  }

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
    for (var song in songsToAdd) {
      if (!targetPlaylist.songs.any((s) => s.audioUrl == song.audioUrl)) {
        targetPlaylist.songs.add(song);
      }
    }
    if (targetPlaylist.coverImageUrl == null ||
        targetPlaylist.coverImageUrl!.isEmpty) {
      if (songsToAdd.isNotEmpty) {
        targetPlaylist.coverImageUrl = songsToAdd.first.albumCoverUrl;
      }
    }
    await savePlaylists(playlists);
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

  Future<List<int>> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList(_favoritesKey);
    return favorites?.map(int.parse).toList() ?? [];
  }

  Future<void> _saveFavoriteIds(List<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> idStrings =
        favoriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_favoritesKey, idStrings);
  }

  // CRITICAL METHOD: The type conversion happens here.
  Future<List<AudioModel>> loadFavorites() async {
    List<int> favoriteIds = await _loadFavoriteIds();
    if (favoriteIds.isEmpty) {
      return [];
    }
    try {
      final String idsString = favoriteIds.join(',');
      final response = await http.get(Uri.parse(
          'https://anoopam.org/wp-json/mobile/v1/tracks?ids=$idsString'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // This is the line that performs the type conversion.
        return jsonResponse
            .map((json) => AudioModel.fromApiJson(json))
            .toList();
      } else {
        return Future.error(
            'Failed to load favorite songs from API. Status: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Error fetching favorites: $e');
    }
  }

  Future<void> toggleFavoriteSong(AudioModel song) async {
    List<int> favoriteIds = await _loadFavoriteIds();
    if (favoriteIds.contains(song.id)) {
      favoriteIds.remove(song.id);
    } else {
      favoriteIds.add(song.id!);
    }
    await _saveFavoriteIds(favoriteIds);
  }

  Future<bool> isSongFavorite(AudioModel song) async {
    List<int> favoriteIds = await _loadFavoriteIds();
    return favoriteIds.contains(song.id);
  }
}
