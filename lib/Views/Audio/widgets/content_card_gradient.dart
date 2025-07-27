import 'package:flutter/material.dart';
import 'dart:math';

// Helper function to provide different LinearGradient instances
LinearGradient getContentCardGradient({int? index}) {
  final List<List<Color>> gradients = [
    [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)], // Original Purple
    [const Color(0xFF42A5F5), const Color(0xFF1976D2)], // Blue
    [const Color(0xFF66BB6A), const Color(0xFF388E3C)], // Green
    [const Color(0xFFFF7043), const Color(0xFFE64A19)], // Orange
    [const Color(0xFF7E57C2), const Color(0xFF5E35B1)], // Amethyst
    [const Color(0xFFEF5350), const Color(0xFFD32F2F)], // Red
    [const Color(0xFFAB47BC), const Color(0xFF7B1FA2)], // Deep Purple (alternative)
    [const Color(0xFF26C6DA), const Color(0xFF0097A7)], // Cyan
  ];

  if (index != null && index >= 0 && index < gradients.length) {
    return LinearGradient(
      colors: gradients[index],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  } else {
    // If no index is provided or invalid, return a random gradient
    final random = Random();
    return LinearGradient(
      colors: gradients[random.nextInt(gradients.length)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
