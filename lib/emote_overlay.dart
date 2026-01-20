import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/overlay_provider.dart';
import '../widgets/emote_wheel.dart';
import '../widgets/arc_clipper.dart';
import '../main.dart';

class EmoteOverlay extends StatefulWidget {
  const EmoteOverlay({super.key});

  @override
  State<EmoteOverlay> createState() => _EmoteOverlayState();
}

class _EmoteOverlayState extends State<EmoteOverlay> 
    with TickerProviderStateMixin {
  late AnimationController _visibilityController;
  late AnimationController _popController;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );

    // Start with overlay visible for demo
    _showOverlay();
  }

  @override
  void dispose() {
    _visibilityController.dispose();
    _popController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    setState(() {
      _isVisible = true;
    });
    _visibilityController.forward();
  }

  void _hideOverlay() {
    _visibilityController.reverse().then((_) {
      setState(() {
        _isVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Transparent background to capture touches
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // Emote wheel overlay
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _visibilityController,
              child: Consumer<OverlayProvider>(
                builder: (context, provider, child) {
                  return AnimatedBuilder(
                    animation: _visibilityController,
                    builder: (context, child) {
                      final double animationOffset = 1.0 - _visibilityController.value;
                      final screenSize = MediaQuery.of(context).size;
                      
                      // Responsive wheel width with constraints
                      const double maxWheelWidth = 600.0;
                      const double minWheelWidth = 280.0;
                      final double wheelWidth = (screenSize.width * 0.6).clamp(minWheelWidth, maxWheelWidth);
                      
                      // Responsive positioning based on screen size
                      final double offsetMultiplier = screenSize.width < 800 ? 0.4 : 0.3;
                      final double baseOffset = screenSize.width < 600 ? wheelWidth * 0.3 : wheelWidth * 0.5;
                      
                      return Positioned(
                        left: -baseOffset - (animationOffset * wheelWidth * offsetMultiplier),
                        top: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: const SizedBox.shrink(),
                      );
                    },
                    child: ClipPath(
                      clipper: ArcClipper(),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _popController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    provider.selectEmote();
                                    _hideOverlay();
                                  },
                                  onVerticalDragUpdate: (details) =>
                                      provider.handlePanUpdate(details, _popController),
                                  child: EmoteWheel(
                                    scrollAngle: provider.scrollAngle,
                                    emotes: provider.emotes,
                                    focusedIndex: provider.focusedEmoteIndex,
                                    popAnimation: _popController.value,
                                  ),
                                ),
                                // Close button
                                ClipOval(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                    child: GestureDetector(
                                      onTap: _hideOverlay,
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
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Toggle handle
          const Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: OverlayHandle(),
          ),
        ],
      ),
    );
  }
}

class OverlayHandle extends StatelessWidget {
  const OverlayHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppSpacing.xl,
        height: AppSpacing.xxl + AppSpacing.xl + AppSpacing.md,
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
            )
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
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
              size: AppSpacing.lg + AppSpacing.xs,
            ),
          ),
        ),
      ),
    );
  }
}
