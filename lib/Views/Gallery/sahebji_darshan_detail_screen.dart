// lib/screens/sahebji_darshan_detail_screen.dart

import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:anoopam_mission/models/sahebji_darshan_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'photo_detail_screen.dart';

class SahebjiDarshanDetailScreen extends StatefulWidget {
  final int albumId;

  const SahebjiDarshanDetailScreen({super.key, required this.albumId});

  @override
  State<SahebjiDarshanDetailScreen> createState() =>
      _SahebjiDarshanDetailScreenState();
}

class _SahebjiDarshanDetailScreenState
    extends State<SahebjiDarshanDetailScreen> {
  SahebjiDarshanDetails? _details;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details =
          await PhotoApiService.getSahebjiDarshanDetails(widget.albumId);
      if (!mounted) return;
      setState(() {
        _details = details;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _details != null
            ? Text(
                _details!.title
                    .split(',')
                    .last
                    .trim(), // Assuming the location is at the end of the title
              )
            : const Text('Sahebji Darshan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _details == null
                  ? const Center(child: Text('No details found.'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _details!.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Assuming the date is part of the title or can be extracted.
                            // If the date is not available, this can be removed.
                            // The mockup shows the date in the app bar, which is
                            // not feasible from the current details API response.
                            // For simplicity, let's put it in the body.
                            if (_details!.title.contains('2024'))
                              Text(
                                _details!.title.substring(
                                    _details!.title.indexOf('2024') - 7),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _details!.sahebjiDarshan.length,
                              itemBuilder: (context, index) {
                                final imageItem =
                                    _details!.sahebjiDarshan[index];
                                final imageUrl = imageItem.image;
                                final caption = imageItem.caption;

                                return GestureDetector(
                                  onTap: () {
                                    final tempPhoto = Photo(
                                      id: index,
                                      albumId: widget.albumId,
                                      imageUrl: imageUrl,
                                      country: '',
                                      state: '',
                                      lastUpdated: DateTime.now(),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PhotoDetailScreen(photo: tempPhoto),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                          color: Colors.grey)),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            color: Colors.black54,
                                            child: Text(
                                              caption,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
