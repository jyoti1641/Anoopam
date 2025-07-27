import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anoopam_mission/providers/theme_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dummy notification data - replace with actual data
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Brahmanirzar',
      'subtitle': 'Monthly Newsletter',
      'description': 'New monthly newsletter is now available for download.',
      'date': '2 hours ago',
      'image': 'assets/icons/brahmanirzar.png',
      'isRead': false,
    },
    {
      'title': 'New Audio Release',
      'subtitle': 'Bhajan Collection 2024',
      'description': 'Listen to the latest collection of spiritual bhajans.',
      'date': '1 day ago',
      'image': 'assets/icons/audios.png',
      'isRead': true,
    },
    {
      'title': 'Upcoming Event',
      'subtitle': 'Spiritual Discourse',
      'description': 'Join us for a special spiritual discourse this weekend.',
      'date': '3 days ago',
      'image': 'assets/icons/events.png',
      'isRead': true,
    },
    {
      'title': 'Video Update',
      'subtitle': 'Morning Aarti',
      'description': 'Watch the complete morning aarti ceremony.',
      'date': '1 week ago',
      'image': 'assets/icons/videos.png',
      'isRead': true,
    },
    {
      'title': 'Donation Reminder',
      'subtitle': 'Support Our Mission',
      'description':
          'Your contribution helps us continue our spiritual mission.',
      'date': '2 weeks ago',
      'image': 'assets/icons/donation.png',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
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
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.04,
                    ),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage(notification['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (!notification['isRead'])
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            notification['title'],
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notification['subtitle'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['description'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.6),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['date'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                              ),
                            ],
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
                            // Handle notification tap
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Opening ${notification['title']}'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
