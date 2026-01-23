import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/overlay_provider.dart';
import 'package:myapp/widgets/emote_wheel.dart';

class GamingOverlay extends StatefulWidget {
  const GamingOverlay({super.key});

  @override
  State<GamingOverlay> createState() => _GamingOverlayState();
}

class _GamingOverlayState extends State<GamingOverlay>
    with TickerProviderStateMixin {
  bool _showWheel = false;
  late AnimationController _wheelController;

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void _toggleWheel() {
    setState(() {
      _showWheel = !_showWheel;
    });
    
    if (_showWheel) {
      _wheelController.forward();
    } else {
      _wheelController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Trigger button
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _toggleWheel,
              child: Container(
                width: 60,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(102),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff00f0b4).withAlpha(51),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(
                      child: Icon(
                        _showWheel ? Icons.close : Icons.emoji_emotions,
                        color: const Color(0xff00f0b4),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Emote wheel
          if (_showWheel)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleWheel,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(153),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xff00f0b4).withAlpha(102),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Consumer<OverlayProvider>(
                            builder: (context, provider, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      provider.selectEmote();
                                      _toggleWheel();
                                    },
                                    onVerticalDragUpdate: (details) {
                                      final dummyController = AnimationController(
                                        vsync: this,
                                        duration: const Duration(milliseconds: 150),
                                      );
                                      provider.handlePanUpdate(details, dummyController);
                                      dummyController.dispose();
                                    },
                                    child: EmoteWheel(
                                      scrollAngle: provider.scrollAngle,
                                      emotes: provider.emotes,
                                      focusedIndex: provider.focusedEmoteIndex,
                                      popAnimation: 0.0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _toggleWheel,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(102),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xff00f0b4).withAlpha(51),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Color(0xff00f0b4),
                                        size: 24,
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}
