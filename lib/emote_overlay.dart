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
  late AnimationController _popController;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 350),
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
                _buildEmoteWheelUI(provider, context),
              ],

              // Show handle only when the wheel is not visible and not animating
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
  Widget _buildEmoteWheelUI(OverlayProvider provider, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Responsive wheel width with constraints, matching the main app's implementation
    const double maxWheelWidth = 600.0;
    const double minWheelWidth = 280.0;
    final double wheelWidth = (screenSize.width * 0.6).clamp(
      minWheelWidth,
      maxWheelWidth,
    );

    // The wheel should be positioned mostly off-screen when closed.
    // An offset of about 40% of its width is a good starting point.
    final double closedOffset = -(wheelWidth * 0.4);

    return AnimatedBuilder(
      animation: _visibilityController,
      builder: (context, child) {
        // Animate the position from the closed offset to fully visible (left: 0)
        final double left =
            lerpDouble(closedOffset, 0, _visibilityController.value)!;
        return Positioned(
          left: left,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
          child: child!,
        );
      },
      child: FadeTransition(
        opacity: _visibilityController, // Also fade it in for a smoother look
        child: ClipPath(
          clipper: ArcClipper(),
          child: SizedBox(
            width: wheelWidth, // Constrain the wheel's size
            child: Center(
              // Center the content within the Arc
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
