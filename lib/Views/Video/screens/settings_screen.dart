import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/watch_history_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Section
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                  );
                },
              ),
            ],
          ),

          // Data Management Section
          _buildSection(
            context,
            title: 'Data Management',
            children: [
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorites'),
                subtitle: Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    return Text('${favoritesProvider.favoritesCount} videos');
                  },
                ),
                trailing: Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    if (favoritesProvider.favorites.isNotEmpty) {
                      return TextButton(
                        onPressed: () => _showClearFavoritesDialog(context),
                        child: const Text('Clear'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Watch History'),
                subtitle: Consumer<WatchHistoryProvider>(
                  builder: (context, historyProvider, child) {
                    return Text('${historyProvider.historyCount} videos');
                  },
                ),
                trailing: Consumer<WatchHistoryProvider>(
                  builder: (context, historyProvider, child) {
                    if (historyProvider.watchHistory.isNotEmpty) {
                      return TextButton(
                        onPressed: () => _showClearHistoryDialog(context),
                        child: const Text('Clear'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),

          // About Section
          _buildSection(
            context,
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Made with Flutter'),
                subtitle: const Text('YouTube Channel App'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showClearFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
          'Are you sure you want to remove all videos from your favorites? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FavoritesProvider>().clearFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Watch History'),
        content: const Text(
          'Are you sure you want to clear your entire watch history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WatchHistoryProvider>().clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Watch history cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
} 