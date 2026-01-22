import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/overlay_provider.dart';
import 'providers/overlay_service.dart';
import 'widgets/arc_clipper.dart';
import 'widgets/emote_wheel.dart';
import 'home_screen.dart';

// Consistent spacing system (8px grid)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OverlayService()),
        ChangeNotifierProvider(create: (_) => OverlayProvider()),
      ],
      child: MaterialApp(
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
        home: const HomeScreen(),
      ),
    );
  }
}

class GamingOverlay extends StatefulWidget {
  const GamingOverlay({super.key});

  @override
  State<GamingOverlay> createState() => _GamingOverlayState();
}

class _GamingOverlayState extends State<GamingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _visibilityController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _popController;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 350),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(-0.5, 0.0), // Start partially off-screen
          end: const Offset(0.0, 0.0), // End fully on-screen
        ).animate(
          CurvedAnimation(
            parent: _visibilityController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OverlayProvider>(context, listen: false);
      provider.addListener(() {
        if (provider.isOverlayVisible) {
          _visibilityController.forward();
        } else {
          _visibilityController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _visibilityController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const Background(),
            Align(
              alignment: Alignment.centerLeft,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _visibilityController,
                  child: Consumer<OverlayProvider>(
                    builder: (context, provider, child) {
                      return ClipPath(
                        clipper:
                            ArcClipper(), // Clipper now works with the aligned widget
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _popController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: provider.selectEmote,
                                    onVerticalDragUpdate: (details) =>
                                        provider.handlePanUpdate(
                                          details,
                                          _popController,
                                        ),
                                    child: EmoteWheel(
                                      scrollAngle: provider.scrollAngle,
                                      emotes: provider.emotes,
                                      focusedIndex: provider.focusedEmoteIndex,
                                      popAnimation: _popController.value,
                                    ),
                                  ),
                                  ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10.0,
                                        sigmaY: 10.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: provider.dismissOverlay,
                                        child: Container(
                                          width: AppSpacing.xl + AppSpacing.xl,
                                          height: AppSpacing.xl + AppSpacing.xl,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(76),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: AppSpacing.lg + AppSpacing.sm,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const RightHandle(),
          ],
        ),
      ),
    );
  }
}

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withAlpha((255 * 0.8).toInt()),
            const Color(0xff1a1a2e),
            Colors.black.withAlpha((255 * 0.9).toInt()),
          ],
        ),
      ),
    );
  }
}

class RightHandle extends StatelessWidget {
  const RightHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OverlayProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    // Responsive handle dimensions
    final double handleWidth = screenSize.width < 600
        ? AppSpacing.lg
        : AppSpacing.xl;
    final double handleHeight = screenSize.height < 600
        ? AppSpacing.xxl + AppSpacing.lg
        : AppSpacing.xxl + AppSpacing.xl + AppSpacing.md;

    return Positioned(
      right: 0,
      top: AppSpacing.sm,
      bottom: AppSpacing.sm,
      child: Center(
        child: GestureDetector(
          onTap: provider.toggleOverlay,
          child: Container(
            width: handleWidth,
            height: handleHeight,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(102),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.lg),
                bottomLeft: Radius.circular(AppSpacing.lg),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withAlpha(51),
                  blurRadius: AppSpacing.sm + AppSpacing.xs,
                  spreadRadius: AppSpacing.xs,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.lg),
                bottomLeft: Radius.circular(AppSpacing.lg),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Icon(
                  provider.isOverlayVisible
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: Theme.of(context).primaryColor,
                  size: handleWidth * 0.75, // Responsive icon size
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
