import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anoopam_mission/providers/theme_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filterKeys = [
    'All',
    'Videos',
    'Audios',
    'Events',
    'Brahmanirzar'
  ];

  List<String> get _filters => _filterKeys;

  // Dummy search results - replace with actual data
  final List<Map<String, dynamic>> _searchResults = [
    {
      'title': 'Bhajan Collection 2024',
      'subtitle': 'Album • Rahul Patel',
      'image': 'assets/icons/audios.png',
      'type': 'Audios',
    },
    {
      'title': 'Morning Aarti',
      'subtitle': 'Video • 15 min',
      'image': 'assets/icons/videos.png',
      'type': 'Videos',
    },
    {
      'title': 'Spiritual Discourse',
      'subtitle': 'Event • March 15, 2024',
      'image': 'assets/icons/events.png',
      'type': 'Events',
    },
    {
      'title': 'Daily Mantra',
      'subtitle': 'Brahmanirzar • 5 min',
      'image': 'assets/icons/brahmanirzar.png',
      'type': 'Brahmanirzar',
    },
    {
      'title': 'Evening Bhajan',
      'subtitle': 'Album • Priya Sharma',
      'image': 'assets/icons/audios.png',
      'type': 'Audios',
    },
  ];

  List<Map<String, dynamic>> get _filteredResults {
    if (_selectedFilter == 'All') {
      return _searchResults;
    }
    return _searchResults
        .where((result) => result['type'] == _selectedFilter)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          'Search',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Icon(
                        Icons.search,
                        color: Theme.of(context).iconTheme.color,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          hintStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.6),
                                  ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.mic,
                        color: Theme.of(context).iconTheme.color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Tabs
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterKeys.asMap().entries.map((entry) {
                    final index = entry.key;
                    final filterKey = entry.value;
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filterKey;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filterKey;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.7),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Results List
            Expanded(
              child: _filteredResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.6),
                                    ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredResults.length,
                      itemBuilder: (context, index) {
                        final result = _filteredResults[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12.0),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage(result['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              result['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                            ),
                            subtitle: Text(
                              result['subtitle'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.7),
                                  ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.5),
                            ),
                            onTap: () {
                              // Handle item tap - navigate to detail screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening ${result['title']}'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
