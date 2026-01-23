
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const GamingOverlay(),
      ),
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow both orientations for home screen
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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
  bool _isOverlayActive = false;

  @override
  void initState() {
    super.initState();
    _checkOverlayStatus();
  }

  Future<void> _checkOverlayStatus() async {
    final isGranted = await SystemAlertWindow.checkPermissions();
    if (isGranted == true) {
      // Note: isOverlayActive might not be available in this version
      // We'll assume overlay is inactive on startup
      setState(() {
        _isOverlayActive = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions();
  }

  Future<void> _toggleOverlay() async {
    final hasPermission = await SystemAlertWindow.checkPermissions();
    if (hasPermission != true) {
      await _requestPermissions();
      return;
    }

    if (_isOverlayActive) {
      await SystemAlertWindow.closeSystemWindow();
      setState(() {
        _isOverlayActive = false;
      });
    } else {
      // Show minimal trigger overlay - not the full wheel
      SystemAlertWindow.showSystemWindow(
        height: 120,
        width: 60,
        gravity: SystemWindowGravity.RIGHT,
        notificationTitle: "Emote Overlay",
        notificationBody: "Tap to show emote wheel",
        prefMode: SystemWindowPrefMode.OVERLAY,
      );
      setState(() {
        _isOverlayActive = true;
      });
    }
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xff1a1a2e),
                Colors.black87,
                const Color(0xff0f0f1e),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.emoji_emotions_outlined,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Xist Emote Overlay',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Floating emote wheel that works over any app',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withAlpha(51),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOverlayActive ? Icons.check_circle : Icons.info_outline,
                              color: _isOverlayActive 
                                ? Colors.green 
                                : Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _isOverlayActive 
                                ? 'Overlay Active' 
                                : 'Overlay Inactive',
                              style: TextStyle(
                                color: _isOverlayActive 
                                  ? Colors.green 
                                  : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _isOverlayActive 
                            ? 'Floating trigger is visible on screen'
                            : 'Enable overlay to see floating trigger',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ElevatedButton.icon(
                    onPressed: _toggleOverlay,
                    icon: Icon(
                      _isOverlayActive ? Icons.stop : Icons.play_arrow,
                    ),
                    label: Text(
                      _isOverlayActive ? 'Stop Overlay' : 'Start Overlay',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      backgroundColor: _isOverlayActive 
                        ? Colors.red.withAlpha(51)
                        : Theme.of(context).primaryColor.withAlpha(51),
                      foregroundColor: _isOverlayActive 
                        ? Colors.red
                        : Theme.of(context).primaryColor,
                      textStyle: Theme.of(context).textTheme.titleLarge,
                      side: BorderSide(
                        color: _isOverlayActive 
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'The overlay will appear as a small floating trigger\nTap it to show the emote wheel',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
