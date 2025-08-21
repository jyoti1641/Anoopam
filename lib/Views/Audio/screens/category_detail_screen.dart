// lib/Views/Audio/screens/category_detail_screen.dart

import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/category_item.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:anoopam_mission/Views/Audio/widgets/audio_grid_item.dart';

class CategoryDetailScreen extends StatefulWidget {
 final CategoryItem category;
 const CategoryDetailScreen({super.key, required this.category});

 @override
 State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
 late Future<Map<String, dynamic>> _categoryContentFuture;
 final ApiService _apiService = ApiService();

 @override
 void initState() {
  super.initState();
  _fetchData();
 }

 Future<void> _fetchData() async {
  setState(() {
   _categoryContentFuture = _apiService.fetchCategoryContent(widget.category.id);
  });
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   backgroundColor: Theme.of(context).colorScheme.surface,
   appBar: AppBar(
    title: Text(widget.category.title),
    backgroundColor: Theme.of(context).colorScheme.surface,
    leading: IconButton(
     icon: const Icon(Icons.arrow_back),
     onPressed: () => Navigator.of(context).pop(),
     color: Theme.of(context).colorScheme.onSurface,
    ),
    actions: [
     IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
       // Implement search functionality
      },
      color: Theme.of(context).colorScheme.onSurface,
     ),
     const SizedBox(width: 10),
     IconButton(
      icon: const Icon(Icons.list),
      onPressed: () {
       // Implement different view mode
      },
      color: Theme.of(context).colorScheme.onSurface,
     ),
     const SizedBox(width: 10),
    ],
   ),
   body: RefreshIndicator(
    onRefresh: _fetchData,
    child: FutureBuilder<Map<String, dynamic>>(
     future: _categoryContentFuture,
     builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
       return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
       return Center(
        child: Text('audio.errorLoadingData'.tr()),
       );
      }
      if (!snapshot.hasData || (snapshot.data!['posts'] as List).isEmpty) {
       return const Center(child: Text('No albums found for this category.'));
      }

      // The corrected line is below:
      final List<AlbumModel> albums = (snapshot.data!['posts'] as List)
        .map((item) => AlbumModel.fromLatestOrFeaturedJson(item))
        .toList();

      return GridView.builder(
       padding: const EdgeInsets.all(16.0),
       itemCount: albums.length,
       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
       ),
       itemBuilder: (context, index) {
        return AudioGridItem(album: albums[index]);
       },
      );
     },
    ),
   ),
  );
 }
}