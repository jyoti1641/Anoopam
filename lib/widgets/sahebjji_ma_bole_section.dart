import 'package:anoopam_mission/widgets/gradient.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:anoopam_mission/models/audio_item.dart';
import 'package:anoopam_mission/widgets/content_card.dart';
import 'package:just_audio/just_audio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:anoopam_mission/Views/Audio/models/album.dart';

class SahebjjiMaBoleSection extends StatefulWidget {
  const SahebjjiMaBoleSection({super.key});

  @override
  State<SahebjjiMaBoleSection> createState() => _SahebjjiMaBoleSectionState();
}

class _SahebjjiMaBoleSectionState extends State<SahebjjiMaBoleSection> {
  Future<List<AlbumModel>> _albumsFuture = Future.value([]);
  Future<List<Playlist>> _playlistsFuture = Future.value([]);
  final PlaylistService _playlistService = PlaylistService();
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _albumsFuture = ApiService().fetchAlbums();
      _playlistsFuture =
          _playlistService.loadPlaylists().then((allPlaylists) async {
        final favoritesPlaylist =
            await _playlistService.getOrCreateFavoritesPlaylist();
        if (!allPlaylists
            .any((p) => p.name == PlaylistService.favoritesPlaylistName)) {
          allPlaylists.add(favoritesPlaylist);
        }
        allPlaylists.sort((a, b) {
          if (a.name == PlaylistService.favoritesPlaylistName) return -1;
          if (b.name == PlaylistService.favoritesPlaylistName) return 1;
          return a.name.compareTo(b.name);
        });
        return allPlaylists;
      });
    });
  }

  Future<void> _refreshAllData() async {
    await _fetchData();
  }

  void _createNewPlaylist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: null,
          playlistService: _playlistService,
          onPlaylistsUpdated: _refreshAllData,
        ),
      ),
    ).then((_) {
      _refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              const Image(
                image: AssetImage('assets/icons/enlighten.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text(
                'menu.sahebjjiMaBole'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.18,
            child: FutureBuilder<List<AlbumModel>>(
              future: _albumsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'audio.errorLoadingAlbums'
                                .tr(args: ['${snapshot.error!}']),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshAllData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Text('audio.retry'.tr()),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'audio.noAlbumsFound'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                if (_isSearching && _searchQuery.isNotEmpty) {
                  List<AudioModel> allSongs = [];
                  for (var album in snapshot.data!) {
                    allSongs.addAll(album.songs);
                  }
                  List<AudioModel> filteredSongs = allSongs
                      .where((song) => song.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                  if (filteredSongs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'audio.noSongsFound'.tr(args: [_searchQuery]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }
                  return SongList(
                    songs: filteredSongs,
                    playlistService: PlaylistService(),
                  );
                } else {
                  List<AlbumModel> filteredAlbums = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 0.45,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filteredAlbums.length,
                    itemBuilder: (context, index) {
                      final album = filteredAlbums[index];
                      // Use the gradient based on the index
                      Gradient gradient = gradients[index % gradients.length];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumDetailScreen(
                                album: album,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Theme.of(context).colorScheme.surface,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.17,
                            decoration: BoxDecoration(
                              gradient: gradient,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 130,
                                    height: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(
                                        album.albumArt,
                                        fit: BoxFit.fill,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 200,
                                            width: 200,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            child: Icon(
                                              Icons.album,
                                              size: 60,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8, right: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 150,
                                          child: Text(
                                            album.albumDate,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          width: 150,
                                          child: Text(
                                            album.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                            child: const SizedBox(height: 4)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  album.albumDuration,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 20,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Play',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
