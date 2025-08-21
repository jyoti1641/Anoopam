// // lib/Views/Audio/services/playlist_service.dart
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
// import 'package:anoopam_mission/Views/Audio/models/song.dart';

// class PlaylistService {
//   static const _playlistsKey = 'user_playlists';
//   static const String favoritesPlaylistName =
//       'Favorites'; // Constant for favorites playlist

//   Future<List<Playlist>> loadPlaylists() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? playlistsJson = prefs.getString(_playlistsKey);
//     if (playlistsJson == null) {
//       return [];
//     }
//     try {
//       final List<dynamic> jsonList = json.decode(playlistsJson);
//       return jsonList
//           .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       print('Error decoding playlists from SharedPreferences: $e');
//       return [];
//     }
//   }

//   Future<void> savePlaylists(List<Playlist> playlists) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<Map<String, dynamic>> jsonList =
//         playlists.map((playlist) => playlist.toJson()).toList();
//     await prefs.setString(_playlistsKey, json.encode(jsonList));
//   }

//   Future<void> addSongToPlaylist(String playlistName, AudioModel song) async {
//     List<Playlist> playlists = await loadPlaylists();
//     bool playlistFound = false;

//     for (var playlist in playlists) {
//       if (playlist.name == playlistName) {
//         if (!playlist.songs.any((s) => s.audioUrl == song.audioUrl)) {
//           playlist.songs.add(song);
//         }
//         playlistFound = true;
//         break;
//       }
//     }

//     if (!playlistFound) {
//       // Create a new playlist if it doesn't exist
//       playlists.add(Playlist(name: playlistName, songs: [song]));
//     }

//     await savePlaylists(playlists);
//   }

//   Future<void> removeSongFromPlaylist(
//       String playlistName, AudioModel songToRemove) async {
//     List<Playlist> playlists = await loadPlaylists();
//     for (var playlist in playlists) {
//       if (playlist.name == playlistName) {
//         playlist.songs
//             .removeWhere((song) => song.audioUrl == songToRemove.audioUrl);
//         break; // Assuming playlist names are unique, we can stop after finding it
//       }
//     }
//     await savePlaylists(playlists);
//   }

//   Future<void> deletePlaylist(String playlistName) async {
//     List<Playlist> playlists = await loadPlaylists();
//     playlists.removeWhere((playlist) => playlist.name == playlistName);
//     await savePlaylists(playlists);
//   }

//   // --- Favorites specific methods ---

//   Future<Playlist> getOrCreateFavoritesPlaylist() async {
//     List<Playlist> playlists = await loadPlaylists();
//     Playlist? favoritesPlaylist;

//     try {
//       favoritesPlaylist = playlists.firstWhere(
//         (p) => p.name == favoritesPlaylistName,
//       );
//     } catch (e) {
//       // If not found, create it
//       favoritesPlaylist = Playlist(name: favoritesPlaylistName, songs: []);
//       playlists.add(favoritesPlaylist);
//       await savePlaylists(
//           playlists); // Save the newly created favorites playlist
//     }
//     return favoritesPlaylist;
//   }

//   Future<void> toggleFavoriteSong(AudioModel song) async {
//     Playlist favoritesPlaylist = await getOrCreateFavoritesPlaylist();
//     bool isCurrentlyFavorite =
//         favoritesPlaylist.songs.any((s) => s.audioUrl == song.audioUrl);

//     if (isCurrentlyFavorite) {
//       await removeSongFromPlaylist(favoritesPlaylistName, song);
//     } else {
//       await addSongToPlaylist(favoritesPlaylistName, song);
//     }
//   }

//   Future<bool> isSongFavorite(AudioModel song) async {
//     Playlist favoritesPlaylist = await getOrCreateFavoritesPlaylist();
//     return favoritesPlaylist.songs.any((s) => s.audioUrl == song.audioUrl);
//   }
// }

// lib/Views/Audio/services/playlist_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';

class PlaylistService {
  static const _playlistsKey = 'user_playlists';
  static const String favoritesPlaylistName =
      'Favorites'; // Constant for favorites playlist

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

  Future<void> addSongToPlaylist(String playlistName, AudioModel song) async {
    List<Playlist> playlists = await loadPlaylists();
    bool playlistFound = false;

    for (var playlist in playlists) {
      if (playlist.name == playlistName) {
        if (!playlist.songs.any((s) => s.audioUrl == song.audioUrl)) {
          playlist.songs.add(song);
        }
        playlistFound = true;
        break;
      }
    }

    if (!playlistFound) {
      // Create a new playlist if it doesn't exist
      playlists.add(Playlist(name: playlistName, songs: [song]));
    }

    await savePlaylists(playlists);
  }

  // New method: Add multiple songs to a playlist
  Future<void> addSongsToPlaylist(
      String playlistName, List<AudioModel> songsToAdd) async {
    List<Playlist> playlists = await loadPlaylists();
    Playlist? targetPlaylist;

    // Find the playlist
    try {
      targetPlaylist = playlists.firstWhere((p) => p.name == playlistName);
    } catch (e) {
      // If not found, create a new playlist
      targetPlaylist = Playlist(name: playlistName, songs: []);
      playlists.add(targetPlaylist);
    }

    // Add songs to the target playlist, avoiding duplicates
    for (var song in songsToAdd) {
      if (!targetPlaylist.songs.any((s) => s.audioUrl == song.audioUrl)) {
        targetPlaylist.songs.add(song);
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
        break; // Assuming playlist names are unique, we can stop after finding it
      }
    }
    await savePlaylists(playlists);
  }

  Future<void> deletePlaylist(String playlistName) async {
    List<Playlist> playlists = await loadPlaylists();
    playlists.removeWhere((playlist) => playlist.name == playlistName);
    await savePlaylists(playlists);
  }

  // --- Favorites specific methods ---

  Future<Playlist> getOrCreateFavoritesPlaylist() async {
    List<Playlist> playlists = await loadPlaylists();
    Playlist? favoritesPlaylist;

    try {
      favoritesPlaylist = playlists.firstWhere(
        (p) => p.name == favoritesPlaylistName,
      );
    } catch (e) {
      // If not found, create it
      favoritesPlaylist = Playlist(name: favoritesPlaylistName, songs: []);
      playlists.add(favoritesPlaylist);
      await savePlaylists(
          playlists); // Save the newly created favorites playlist
    }
    return favoritesPlaylist;
  }

  Future<void> toggleFavoriteSong(AudioModel song) async {
    Playlist favoritesPlaylist = await getOrCreateFavoritesPlaylist();
    bool isCurrentlyFavorite =
        favoritesPlaylist.songs.any((s) => s.audioUrl == song.audioUrl);

    if (isCurrentlyFavorite) {
      await removeSongFromPlaylist(favoritesPlaylistName, song);
    } else {
      await addSongToPlaylist(favoritesPlaylistName, song);
    }
  }

  Future<bool> isSongFavorite(AudioModel song) async {
    Playlist favoritesPlaylist = await getOrCreateFavoritesPlaylist();
    return favoritesPlaylist.songs.any((s) => s.audioUrl == song.audioUrl);
  }
}
