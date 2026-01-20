import 'package:flutter/material.dart';
import '../main.dart';

class EmoteSlot extends StatelessWidget {
  final Map<String, dynamic> emote;
  final bool isFocused;
  final double itemSize;

  const EmoteSlot({
    super.key,
    required this.emote,
    this.isFocused = false,
    required this.itemSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: itemSize,
      height: itemSize,
      padding: EdgeInsets.all(AppSpacing.xs), // Added internal padding
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(isFocused ? 25 : 10),
        borderRadius: BorderRadius.circular(
          itemSize * 0.25,
        ), // Responsive border radius
        border: isFocused
            ? Border.all(
                color: primaryColor.withAlpha((255 * 0.5).round()),
                width: 1.0,
              )
            : null,
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: primaryColor.withAlpha((255 * 0.3).round()),
                  blurRadius: AppSpacing.lg + AppSpacing.xs,
                  spreadRadius: AppSpacing.xs,
                ),
                BoxShadow(
                  color: primaryColor.withAlpha((255 * 0.2).round()),
                  blurRadius: AppSpacing.sm + AppSpacing.xs,
                  spreadRadius: AppSpacing.xs,
                ),
              ]
            : [],
      ),
      child: Center(
        child: emote['icon'] != null
            ? Icon(
                emote['icon'],
                color: isFocused ? primaryColor : emote['color'],
                size: itemSize * 0.47, // Responsive icon size
                shadows: isFocused
                    ? [
                        Shadow(
                          color: primaryColor.withAlpha((255 * 0.5).round()),
                          blurRadius: AppSpacing.sm,
                        ),
                      ]
                    : [],
              )
            : Text(
                emote['text'],
                style: TextStyle(
                  color: isFocused ? primaryColor : emote['color'],
                  fontWeight: FontWeight.bold,
                  fontSize: itemSize * 0.28, // Responsive font size
                  shadows: isFocused
                      ? [
                          Shadow(
                            color: primaryColor.withAlpha((255 * 0.5).round()),
                            blurRadius: AppSpacing.sm,
                          ),
                        ]
                      : [],
                ),
              ),
      ),
    );
  }
}
