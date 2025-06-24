import 'package:flutter/material.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text('Reading'),
          backgroundColor: Colors.white,
          elevation: 1,
          surfaceTintColor: Colors.white,
        ),
      ),
      body: Center(
        child: Text(
          'This is the Reading Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}