import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/overlay_service.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a0a0a),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: AppSpacing.xxl),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMainCard(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSettingsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff00f0b4), Color(0xff00d4ff)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.black,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xist Emote',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Gaming Overlay System',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withAlpha(153),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Consumer<OverlayService>(
      builder: (context, overlayService, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xff1a1a2e).withAlpha(76),
                const Color(0xff16213e).withAlpha(76),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xff00f0b4).withAlpha(51)),
          ),
          child: Column(
            children: [
              Icon(
                overlayService.isOverlayActive ? Icons.layers : Icons.touch_app,
                size: 64,
                color: const Color(0xff00f0b4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                overlayService.isOverlayActive
                    ? 'Overlay Active'
                    : 'Enable Emote Wheel',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                overlayService.isOverlayActive
                    ? 'The emote wheel is currently running on top of other apps'
                    : 'Enable the emote wheel to use it while gaming',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withAlpha(153),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => overlayService.toggleOverlay(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00f0b4),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    overlayService.isOverlayActive
                        ? 'Disable Overlay'
                        : 'Enable Overlay',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Settings',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSettingItem(
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: 'Feel the selection',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.speed,
            title: 'Scroll Speed',
            subtitle: 'Adjust sensitivity',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Customize colors',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xff00f0b4), size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withAlpha(153),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
