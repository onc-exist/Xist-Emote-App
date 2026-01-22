import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:myapp/providers/overlay_provider.dart';
import 'package:myapp/overlay_widget.dart';

// Consistent spacing system (8px grid)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Entry point for the overlay service
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => OverlayProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GamingOverlay(),
      ),
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions;
  }

  void _showOverlay() {
    SystemAlertWindow.showSystemWindow(
      height: 440,
      width: 440,
      gravity: SystemWindowGravity.LEFT,
      notificationTitle: "Emote Overlay Active",
      notificationBody: "Tap to manage the overlay.",
      prefMode: SystemWindowPrefMode.OVERLAY,
      isDisableClicks: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xist Emote App',
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        primaryColor: const Color(0xff00f0b4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff00f0b4),
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Emote Overlay Control'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _showOverlay,
            child: const Text('Show Overlay'),
          ),
        ),
      ),
    );
  }
}
