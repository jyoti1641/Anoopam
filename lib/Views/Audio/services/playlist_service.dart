// lib/Views/Audio/services/playlist_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:anoopam_mission/Views/Audio/models/downloaded_song_model.dart';
import 'package:anoopam_mission/Views/Audio/models/recently_played_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:http/http.dart' as http;

class PlaylistService {
  static const _playlistsKey = 'user_playlists';
  static const _favoritesKey = 'user_favorites';
  static const _key = 'recently_played_albums';
  static const String _appDirectoryName = 'Anoopam Mission Audio';
  static const _downloadsKey = 'downloaded_songs';
  static const _maxItems =
      10; // Maximum number of recently played albums to store

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

  Future<void> saveDownloadedSong(DownloadedSongModel song) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> downloadedSongs = prefs.getStringList(_downloadsKey) ?? [];

    // Convert the new song model to a JSON string.
    final newSongJson = jsonEncode(song.toJson());

    // Add the new song to the list.
    downloadedSongs.add(newSongJson);

    await prefs.setStringList(_downloadsKey, downloadedSongs);
  }

  Future<List<DownloadedSongModel>> getDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> downloadedSongsJson =
        prefs.getStringList(_downloadsKey) ?? [];

    final List<DownloadedSongModel> songs = [];
    for (var itemJson in downloadedSongsJson) {
      try {
        final item = jsonDecode(itemJson);
        songs.add(DownloadedSongModel.fromJson(item));
      } catch (e) {
        print('Error decoding downloaded song: $e');
      }
    }
    return songs;
  }

  // Method to remove a downloaded song and its file.
  Future<void> removeDownloadedSong(DownloadedSongModel song) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> downloadedSongs = prefs.getStringList(_downloadsKey) ?? [];

    // Remove the song from SharedPreferences
    downloadedSongs.removeWhere((itemJson) {
      final item = jsonDecode(itemJson);
      return item['filePath'] == song.filePath;
    });

    await prefs.setStringList(_downloadsKey, downloadedSongs);

    // Also delete the physical file
    final file = File(song.filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<int> getDownloadedSongsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_downloadsKey)?.length ?? 0;
  }

  // This method will be used by your UI to download a song and store its metadata
  Future<void> downloadAndSaveSong(AudioModel song) async {
    final Directory? publicDirectory = await getExternalStorageDirectory();
    final Directory appDownloadsDirectory =
        Directory('${publicDirectory?.path}/Anoopam Mission Audio');
    if (!await appDownloadsDirectory.exists()) {
      await appDownloadsDirectory.create(recursive: true);
    }
    final fileName = '${song.title.replaceAll(RegExp(r'[^\w\s.-]'), '_')}.mp3';
    final filePath = '${appDownloadsDirectory.path}/$fileName';

    final response = await http.get(Uri.parse(song.audioUrl));
    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      final downloadedSong = DownloadedSongModel(
        id: song.id,
        title: song.title,
        artist: song.artist,
        audioDuration: song.audioDuration,
        albumCoverUrl: song.albumCoverUrl,
        filePath: filePath,
      );
      await saveDownloadedSong(downloadedSong);
    } else {
      throw Exception('Failed to download file.');
    }
  }

  Future<void> deletePlaylist(String playlistName) async {
    List<Playlist> playlists = await loadPlaylists();
    playlists.removeWhere((playlist) => playlist.name == playlistName);
    await savePlaylists(playlists);
  }

  Future<void> saveSong(AudioModel song, String albumCoverUrl) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentlyPlayed = prefs.getStringList(_key) ?? [];

    // Create a lightweight model instance from the full AudioModel and the provided URL.
    final newSong = RecentlyPlayedSongModel(
      id: song.id,
      title: song.title,
      artist: song.artist,
      audioDuration: song.audioDuration,
      albumCoverUrl: albumCoverUrl,
      audioUrl: song.audioUrl,
    );

    final newSongJson = jsonEncode(newSong.toJson());

    // Remove the song if it already exists to place it at the top
    recentlyPlayed.removeWhere((itemJson) {
      final item = jsonDecode(itemJson);
      return item['id'] == song.id;
    });

    // Add the most recent song to the start of the list
    recentlyPlayed.insert(0, newSongJson);

    // Trim the list to the maximum number of items
    if (recentlyPlayed.length > _maxItems) {
      recentlyPlayed = recentlyPlayed.sublist(0, _maxItems);
    }

    await prefs.setStringList(_key, recentlyPlayed);
  }

  Future<List<RecentlyPlayedSongModel>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentlyPlayed = prefs.getStringList(_key) ?? [];

    final List<RecentlyPlayedSongModel> songs = [];
    for (var itemJson in recentlyPlayed) {
      try {
        final item = jsonDecode(itemJson);
        songs.add(RecentlyPlayedSongModel.fromJson(item));
      } catch (e) {
        print('Error decoding recently played song: $e');
      }
    }
    return songs;
  }

  // This is the key method to update.
  Future<void> toggleFavoriteSong(AudioModel song, String albumCoverUrl) async {
    if (song.id == null) {
      print('Error: Cannot toggle favorite for a song with null ID.');
      return;
    }

    // Load both ID and album cover URL
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesJson = prefs.getStringList(_favoritesKey);
    List<Map<String, dynamic>> favoritesData = favoritesJson
            ?.map((e) => json.decode(e) as Map<String, dynamic>)
            .toList() ??
        [];

    final isFavorite = favoritesData.any((fav) => fav['id'] == song.id);

    if (isFavorite) {
      favoritesData.removeWhere((fav) => fav['id'] == song.id);
    } else {
      // Save the song ID and album cover URL together
      favoritesData.add({
        'id': song.id,
        'albumCoverUrl': albumCoverUrl,
      });
    }

    final List<String> updatedFavoritesJson =
        favoritesData.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_favoritesKey, updatedFavoritesJson);
  }

  // Updated loadFavorites to merge API data with local album cover
  Future<List<AudioModel>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesJson = prefs.getStringList(_favoritesKey);
    List<Map<String, dynamic>> favoritesData = favoritesJson
            ?.map((e) => json.decode(e) as Map<String, dynamic>)
            .toList() ??
        [];

    if (favoritesData.isEmpty) {
      return [];
    }

    final favoriteIds = favoritesData.map((e) => e['id'] as int).toList();
    final albumCovers = {
      for (var item in favoritesData)
        item['id'] as int: item['albumCoverUrl'] as String?
    };

    try {
      final String idsString = favoriteIds.join(',');
      final response = await http.get(Uri.parse(
          'https://anoopam.org/wp-json/mobile/v1/tracks?ids=$idsString'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        return jsonResponse.map((json) {
          final song = AudioModel.fromApiJson(json);
          // Merge album cover from local storage into the API response
          return AudioModel(
            id: song.id,
            title: song.title,
            audioUrl: song.audioUrl,
            artist: song.artist,
            audioDuration: song.audioDuration,
            albumCoverUrl: albumCovers[song.id] ?? song.albumCoverUrl,
          );
        }).toList();
      } else {
        return Future.error(
            'Failed to load favorite songs from API. Status: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Error fetching favorites: $e');
    }
  }

  Future<bool> isSongFavorite(AudioModel song) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesJson = prefs.getStringList(_favoritesKey);
    List<Map<String, dynamic>> favoritesData = favoritesJson
            ?.map((e) => json.decode(e) as Map<String, dynamic>)
            .toList() ??
        [];
    return favoritesData.any((fav) => fav['id'] == song.id);
  }
}
