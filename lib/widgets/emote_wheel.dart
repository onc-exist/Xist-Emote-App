import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/overlay_provider.dart';
import 'emote_slot.dart';
import 'radial_wheel_painter.dart';
import '../main.dart';

// Final, stateless widget. All state is handled by OverlayProvider.
class EmoteWheel extends StatelessWidget {
  final double scrollAngle;
  final List<Map<String, dynamic>> emotes;
  final int focusedIndex;
  final double popAnimation;

  const EmoteWheel({
    super.key,
    required this.scrollAngle,
    required this.emotes,
    required this.focusedIndex,
    required this.popAnimation,
  });

  @override
  Widget build(BuildContext context) {
    // Enhanced responsive calculations
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    
    // Define breakpoints and constraints
    const double maxWheelWidth = 600.0;
    const double minWheelWidth = 280.0;
    
    // Calculate wheel width with constraints
    final double wheelWidth = (screenWidth * 0.6).clamp(minWheelWidth, maxWheelWidth);
    
    // Responsive item size based on screen density
    final double itemSize = (wheelWidth * 0.07).clamp(40.0, 60.0);
    
    // Adjust visible angle based on screen height
    final double visibleAngle = screenHeight < 600 ? math.pi * 0.8 : math.pi;
    
    const double angleSpacing = OverlayProvider.angleSpacing;

    return SizedBox(
      width: wheelWidth,
      height: screenHeight * 0.8, // Constrain height
      child: LayoutBuilder(builder: (context, constraints) {
        // Responsive radii with minimum/maximum constraints
        final List<double> radii = [
          (wheelWidth * 0.125).clamp(35.0, 75.0), // Inner radius
          (wheelWidth * 0.255).clamp(70.0, 150.0), // Outer radius
        ];
        final double pathRadius = (wheelWidth * 0.19).clamp(50.0, 110.0); // Path radius
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

        return CustomPaint(
          painter: RadialWheelPainter(radii: radii),
          child: Stack(
            children: List.generate(emotes.length, (index) {
              final double itemAngle = (index * angleSpacing) + scrollAngle;
              final bool isFocused = index == focusedIndex;

              final double normalizedItemAngle = math.atan2(math.sin(itemAngle), math.cos(itemAngle));
              final double angleDifference = normalizedItemAngle.abs();

              final double normalizedAngle = (angleDifference / (visibleAngle / 2)).clamp(0.0, 1.0);
              final double scaleFalloff = math.cos(normalizedAngle * math.pi / 2);

              double scale = 0.6 + (scaleFalloff * 0.4);
              double opacity = 0.4 + (scaleFalloff * 0.6);

              if (isFocused) {
                scale = 1.0 + (popAnimation * 0.15);
                opacity = 1.0;
              }

              final double x = center.dx + pathRadius * math.cos(itemAngle);
              final double y = center.dy + pathRadius * math.sin(itemAngle);

              return Positioned(
                left: x - (itemSize * scale / 2),
                top: y - (itemSize * scale / 2),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: EmoteSlot(
                      emote: emotes[index],
                      isFocused: isFocused,
                      itemSize: itemSize,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
