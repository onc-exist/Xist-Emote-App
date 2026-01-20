import 'package:flutter/material.dart';

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Create a path that reveals the right half of the widget.
    // This will clip the radial wheel into a semi-circle or arc.
    final path = Path();
    path.addRect(Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
