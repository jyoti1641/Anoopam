import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CreateNewPlaylistScreen extends StatefulWidget {
  const CreateNewPlaylistScreen({super.key});

  @override
  State<CreateNewPlaylistScreen> createState() =>
      _CreateNewPlaylistScreenState();
}

class _CreateNewPlaylistScreenState extends State<CreateNewPlaylistScreen> {
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        title: Text(
          'playlist.createNew'.tr(), // "Create New Playlist"
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            height: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Go back without creating
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'playlist.givePlaylistName'.tr(), // "Give your playlist name"
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _playlistNameController,
              decoration: InputDecoration(
                hintText: 'playlist.myPlaylist'.tr(), // "My Playlist"
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Pass the new playlist name back to the previous screen
                      Navigator.of(context)
                          .pop(_playlistNameController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff034DA2), // Blue background
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary, // White text
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'playlist.create'.tr(),
                      style: TextStyle(fontSize: 16),
                    ), // "CREATE"
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cancel and go back
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xff034DA2), // Blue text
                      side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary), // Blue border
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'playlist.cancel'.tr(),
                      style: TextStyle(fontSize: 16),
                    ), // "CANCEL"
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
