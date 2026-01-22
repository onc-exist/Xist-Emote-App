import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/overlay_provider.dart';
import '../widgets/emote_wheel.dart';
import '../widgets/arc_clipper.dart';
import '../main.dart';

// This is the root widget for the floating system overlay.
class EmoteOverlay extends StatefulWidget {
  const EmoteOverlay({super.key});

  @override
  State<EmoteOverlay> createState() => _EmoteOverlayState();
}

class _EmoteOverlayState extends State<EmoteOverlay>
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
          begin: const Offset(-0.5, 0.0),
          end: const Offset(0.0, 0.0),
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

    // Listen to the provider to control animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OverlayProvider>(context, listen: false);
      provider.addListener(() {
        if (provider.isOverlayVisible && !_visibilityController.isCompleted) {
          _visibilityController.forward();
        } else if (!provider.isOverlayVisible &&
            _visibilityController.isCompleted) {
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
    // Use a transparent Material widget to ensure correct theme and text rendering
    return Material(
      color: Colors.transparent,
      child: Consumer<OverlayProvider>(
        builder: (context, provider, child) {
          // The overlay is a Stack that shows EITHER the handle OR the wheel
          return Stack(
            children: [
              // Conditionally display the full emote wheel
              if (provider.isOverlayVisible ||
                  _visibilityController.isAnimating) ...[
                _buildEmoteWheelUI(provider),
              ],

              // Always display the handle (it will be covered by the wheel)
              // Or use a more sophisticated way to hide/show it based on state
              if (!provider.isOverlayVisible &&
                  !_visibilityController.isAnimating) ...[
                const Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: OverlayHandle(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Extracts the UI for the emote wheel into a separate, clean method
  Widget _buildEmoteWheelUI(OverlayProvider provider) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _visibilityController,
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
                        onTap: provider.selectEmote,
                        onVerticalDragUpdate: (details) =>
                            provider.handlePanUpdate(details, _popController),
                        child: EmoteWheel(
                          scrollAngle: provider.scrollAngle,
                          emotes: provider.emotes,
                          focusedIndex: provider.focusedEmoteIndex,
                          popAnimation: _popController.value,
                        ),
                      ),
                      // Close button inside the wheel
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
          ),
        ),
      ),
    );
  }
}

// The handle to activate the overlay
class OverlayHandle extends StatelessWidget {
  const OverlayHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OverlayProvider>(context, listen: false);

    return Center(
      child: GestureDetector(
        onTap: provider.showOverlay, // This now calls the provider method
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
                Icons
                    .chevron_right, // Always shows right arrow when handle is visible
                color: Theme.of(context).primaryColor,
                size: AppSpacing.lg + AppSpacing.xs,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
