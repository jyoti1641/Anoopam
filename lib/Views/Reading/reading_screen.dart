import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text('reading.title'.tr()),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 1,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
        ),
      ),
      body: Center(
        child: Text(
          'reading.screen'.tr(),
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
