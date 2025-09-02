// lib/Views/Audio/screens/downloaded_files_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadedFilesScreen extends StatefulWidget {
  const DownloadedFilesScreen({super.key});

  @override
  State<DownloadedFilesScreen> createState() => _DownloadedFilesScreenState();
}

class _DownloadedFilesScreenState extends State<DownloadedFilesScreen> {
  Future<List<File>> _getDownloadedFiles() async {
    final Directory? publicDirectory = await getExternalStorageDirectory();
    if (publicDirectory == null) {
      return [];
    }

    final Directory appDownloadsDirectory =
        Directory('${publicDirectory.path}/Anoopam Mission Audio');

    if (!await appDownloadsDirectory.exists()) {
      return [];
    }

    final files = appDownloadsDirectory
        .listSync(recursive: false, followLinks: false)
        .where((file) => file.path.endsWith('.mp3'))
        .toList();

    return files.cast<File>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Downloads'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: FutureBuilder<List<File>>(
        future: _getDownloadedFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading files.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No downloaded songs found.'));
          }

          final downloadedFiles = snapshot.data!;

          return ListView.builder(
            itemCount: downloadedFiles.length,
            itemBuilder: (context, index) {
              final file = downloadedFiles[index];
              final fileName = file.path.split('/').last;

              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(fileName),
                // You can add an onTap handler here to play the downloaded file
                onTap: () {
                  // TODO: Implement playback of the local file
                  // The file path is `file.path`
                },
              );
            },
          );
        },
      ),
    );
  }
}
