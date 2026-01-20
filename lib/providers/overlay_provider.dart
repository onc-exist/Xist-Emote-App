import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverlayProvider with ChangeNotifier {
  // --- PRIVATE STATE ---
  bool _isOverlayVisible = false; // Start hidden for normal usage
  double _scrollAngle;
  int _focusedEmoteIndex = 3;
  // This could be fetched from a service in a real app
  final List<Map<String, dynamic>> _emotes = [
    {
      'icon': Icons.thumb_up,
      'color': Colors.white,
      'text': null,
      'size': 24.0,
    }, // DECREASED size
    {'icon': null, 'color': Colors.white, 'text': 'GG', 'size': null},
    {
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.yellow.shade400,
      'text': null,
      'size': 28.0,
    }, // DECREASED size
    {
      'icon': Icons.local_fire_department,
      'color': const Color(0xff00f0b4),
      'text': null,
      'size': 28.0,
    }, // DECREASED size
    {
      'icon': Icons.back_hand,
      'color': Colors.blue.shade400,
      'text': null,
      'size': 28.0,
    }, // DECREASED size
    {
      'icon': Icons.favorite,
      'color': Colors.red.shade500,
      'text': null,
      'size': 28.0,
    }, // DECREASED size
    {
      'icon': Icons.celebration,
      'color': Colors.purple.shade300,
      'text': null,
      'size': 28.0,
    }, // DECREASED size
    {'icon': null, 'color': Colors.white, 'text': 'WP', 'size': null},
    {
      'icon': Icons.star,
      'color': Colors.yellow.shade600,
      'text': null,
      'size': 28.0,
    }, // DECREASED size
    {'icon': null, 'color': Colors.white, 'text': 'EZ', 'size': null},
    {
      'icon': Icons.whatshot,
      'color': Colors.orange,
      'text': null,
      'size': 28.0,
    }, // DECREASED size
  ];

  // --- CONSTANTS ---
  static const double angleSpacing = math.pi / 8; // INCREASED spacing

  // --- PUBLIC GETTERS ---
  bool get isOverlayVisible => _isOverlayVisible;
  double get scrollAngle => _scrollAngle;
  int get focusedEmoteIndex => _focusedEmoteIndex;
  List<Map<String, dynamic>> get emotes => _emotes;
  int get emoteCount => _emotes.length;

  // --- CONSTRUCTOR ---
  OverlayProvider()
    : _scrollAngle = -3 * angleSpacing; // Initialize scroll angle

  // --- BUSINESS LOGIC (MUTATORS) ---

  void toggleOverlay() {
    _isOverlayVisible = !_isOverlayVisible;
    developer.log('Overlay toggled: $_isOverlayVisible');
    notifyListeners();
  }

  // New method to only select the emote
  void selectEmote() {
    developer.log(
      "Emote '${_emotes[_focusedEmoteIndex]['text'] ?? _emotes[_focusedEmoteIndex]['icon'].toString()}' selected!",
    );
    // In a real app, you might want to send this to a service
    // or show a brief confirmation animation.
    HapticFeedback.mediumImpact(); // Give feedback on selection
  }

  // New method to dismiss the overlay
  void dismissOverlay() {
    if (_isOverlayVisible) {
      toggleOverlay();
    }
  }

  void handlePanUpdate(
    DragUpdateDetails details,
    AnimationController popController,
  ) {
    // Responsive scroll sensitivity based on screen height
    final double screenHeight = 800.0; // Base reference height
    final double sensitivityFactor = 800.0 / screenHeight;
    final double adjustedSensitivity = 0.015 * sensitivityFactor;

    _scrollAngle += details.delta.dy * -adjustedSensitivity;

    // Calculate the new focused index based on the angle
    int newFocusedIndex = (-_scrollAngle / angleSpacing).round();

    // True circular wrapping for the index
    newFocusedIndex = newFocusedIndex % _emotes.length;

    if (newFocusedIndex != _focusedEmoteIndex) {
      _focusedEmoteIndex = newFocusedIndex;
      HapticFeedback.lightImpact();
      // Trigger the pop animation from the widget that owns the controller
      popController.forward().then((_) => popController.reverse());
    }

    notifyListeners();
  }
}
