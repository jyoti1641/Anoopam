import 'package:flutter/material.dart';

// Define your gradients
final Gradient gradientOne = LinearGradient(
  colors: [Colors.blue, Colors.lightBlueAccent],
  stops: [0.0, 2.0],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

final Gradient gradientTwo = LinearGradient(
  colors: [Colors.purple, Colors.deepPurpleAccent],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final Gradient gradientThree = LinearGradient(
  colors: [Colors.orange, Colors.deepOrangeAccent],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// You can add more gradients as needed
List<Gradient> gradients = [gradientOne, gradientTwo, gradientThree];
