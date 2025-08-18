import 'package:flutter/material.dart';

// Define your gradients
final Gradient gradientOne = LinearGradient(
  colors: [Color(0xff414888), Color(0xff3485C4)],
  stops: [0.0, 2.0],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

final Gradient gradientTwo = LinearGradient(
  colors: [Color(0xff533C8C), Color(0xffCA4991)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final Gradient gradientThree = LinearGradient(
  colors: [Color(0xffEE592F), Color(0xffEEBA52)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
final Gradient gradientFour = LinearGradient(
  colors: [Color(0xff359294), Color(0xff3E86BF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
final Gradient gradientFive = LinearGradient(
  colors: [Color(0xffA91C70), Color(0xffEB5242)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// You can add more gradients as needed
List<Gradient> gradients = [
  gradientOne,
  gradientTwo,
  gradientThree,
  gradientFour,
  gradientFive
];
