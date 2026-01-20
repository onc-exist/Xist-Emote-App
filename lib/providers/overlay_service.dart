import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../emote_overlay.dart';
import 'overlay_provider.dart';

class OverlayService with ChangeNotifier {
  bool _isOverlayActive = false;
  bool _hasPermission = false;
  OverlayEntry? _overlayEntry;

  // Getters
  bool get isOverlayActive => _isOverlayActive;
  bool get hasPermission => _hasPermission;

  OverlayService() {
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.systemAlertWindow.status;
    _hasPermission = status.isGranted;
    notifyListeners();
  }

  Future<void> requestPermission(BuildContext context) async {
    try {
      final status = await Permission.systemAlertWindow.request();
      _hasPermission = status.isGranted;
      
      if (!_hasPermission) {
        // Show dialog to guide user to settings
        if (context.mounted) {
          _showPermissionDialog(context);
        }
      }
      
      notifyListeners();
    } catch (e) {
      developer.log('Error requesting overlay permission: $e');
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overlay Permission Required'),
        content: const Text(
          'To use the emote wheel over other apps, you need to grant overlay permission. '
          'Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> toggleOverlay(BuildContext context) async {
    if (!_hasPermission) {
      await requestPermission(context);
      return;
    }

    if (_isOverlayActive) {
      await _disableOverlay();
    } else {
      await _enableOverlay(context);
    }
    
    notifyListeners();
  }

  Future<void> _enableOverlay(BuildContext context) async {
    try {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }

      // Create overlay entry
      _overlayEntry = OverlayEntry(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => OverlayProvider()),
          ],
          child: const EmoteOverlay(),
        ),
      );

      // Insert overlay
      Overlay.of(context).insert(_overlayEntry!);
      _isOverlayActive = true;
      
      developer.log('Overlay enabled');
      
    } catch (e) {
      developer.log('Error enabling overlay: $e');
      _isOverlayActive = false;
    }
  }

  Future<void> _disableOverlay() async {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayActive = false;
      
      developer.log('Overlay disabled');
      
    } catch (e) {
      developer.log('Error disabling overlay: $e');
    }
  }

  void showEmoteWheel() {
    if (_isOverlayActive && _overlayEntry != null) {
      developer.log('Showing emote wheel');
      // The overlay is always visible when active
    }
  }

  void hideEmoteWheel() {
    if (_isOverlayActive && _overlayEntry != null) {
      developer.log('Hiding emote wheel');
      // The overlay handles its own visibility
    }
  }
}
