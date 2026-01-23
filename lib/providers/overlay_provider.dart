import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverlayProvider with ChangeNotifier {
  static const double angleSpacing = math.pi / 6; // 12 emotes

  final List<Map<String, dynamic>> emotes = [
    {'text': '😂', 'color': Colors.yellow, 'icon': null},
    {'text': '👍', 'color': Colors.blue, 'icon': null},
    {'text': '❤️', 'color': Colors.red, 'icon': null},
    {'text': '🙏', 'color': Colors.orange, 'icon': null},
    {'text': '😮', 'color': Colors.lightBlue, 'icon': null},
    {'text': '😢', 'color': Colors.blueAccent, 'icon': null},
    {'icon': Icons.thumb_up, 'color': Colors.green, 'text': null},
    {'icon': Icons.thumb_down, 'color': Colors.redAccent, 'text': null},
    {'icon': Icons.favorite, 'color': Colors.pink, 'text': null},
    {'icon': Icons.star, 'color': Colors.amber, 'text': null},
    {'icon': Icons.celebration, 'color': Colors.purple, 'text': null},
    {'icon': Icons.help, 'color': Colors.cyan, 'text': null},
  ];

  double _scrollAngle = 0.0;
  int _focusedEmoteIndex = 0;
  bool _isOverlayVisible = false;

  double get scrollAngle => _scrollAngle;
  int get focusedEmoteIndex => _focusedEmoteIndex;
  bool get isOverlayVisible => _isOverlayVisible;

  void handlePanUpdate(
    DragUpdateDetails details,
    AnimationController controller,
  ) {
    _scrollAngle += details.delta.dy / 100.0;

    // Calculate the focused index based on the corrected angle
    final double normalizedAngle = _scrollAngle % (2 * math.pi);
    int newIndex = ((-normalizedAngle / angleSpacing) % emotes.length).round();

    if (newIndex < 0) {
      newIndex += emotes.length;
    }

    if (newIndex != _focusedEmoteIndex) {
      _focusedEmoteIndex = newIndex;
      controller.forward(from: 0.0);
    }

    notifyListeners();
  }

  void toggleOverlay() {
    _isOverlayVisible = !_isOverlayVisible;
    notifyListeners();
  }

  void dismissOverlay() {
    if (_isOverlayVisible) {
      _isOverlayVisible = false;
      notifyListeners();
    }
  }

  // This method is called by the handle to explicitly show the overlay
  void showOverlay() {
    if (!_isOverlayVisible) {
      _isOverlayVisible = true;
      notifyListeners();
    }
  }

  void selectEmote() {
    if (_isOverlayVisible) {
      final selected = emotes[_focusedEmoteIndex];
      
      // Copy emote to clipboard for real functionality
      if (selected['text'] != null) {
        Clipboard.setData(ClipboardData(text: selected['text']));
        developer.log(
          'Emote copied to clipboard',
          name: 'xist.emote_overlay',
          level: 800,
          error: {
            'emote': selected['text'],
            'type': 'unicode',
            'index': _focusedEmoteIndex,
          },
        );
      } else if (selected['icon'] != null) {
        // For icon emotes, copy a text representation
        final iconText = _getIconText(selected['icon']);
        Clipboard.setData(ClipboardData(text: iconText));
        developer.log(
          'Icon emote copied to clipboard',
          name: 'xist.emote_overlay',
          level: 800,
          error: {
            'emote': iconText,
            'type': 'icon',
            'index': _focusedEmoteIndex,
          },
        );
      }
      
      dismissOverlay();
    }
  }

  String _getIconText(IconData icon) {
    // Convert Material Icons to text representations
    if (icon == Icons.thumb_up) return '👍';
    if (icon == Icons.thumb_down) return '👎';
    if (icon == Icons.favorite) return '❤️';
    if (icon == Icons.star) return '⭐';
    if (icon == Icons.celebration) return '🎉';
    if (icon == Icons.help) return '❓';
    return '📱'; // Default fallback
  }
}
