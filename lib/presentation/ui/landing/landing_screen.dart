import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

/// Welcome / landing — tweak spacing & copy against your Figma reference.
/// Figma ref: Smart Travel Companion (Make file).
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const routePath = '/landing';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomBg = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 12,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B52F5), Color(0xFF8B84FF), Color(0xFFABA4FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: Colors.white24),
                            onPressed: () => context.go('/home'),
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smart Travel Companion',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Explore curated places, live weather,\nand maps — built for travellers who '
                            'love a polished, modern companion.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: .92),
                                  height: 1.45,
                                ),
                          ),
                          const SizedBox(height: 28),
                          const Expanded(child: _HeroCollage()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 11,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: bottomBg),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        140 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Everything in one trip',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                          ),
                          const SizedBox(height: 22),
                          _FeatureTile(
                            icon: Icons.photo_library_outlined,
                            title: 'Places from JSONPlaceholder',
                            subtitle: 'Curated titles & imagery synced to SQLite for smooth Explore.',
                          ),
                          const SizedBox(height: 14),
                          _FeatureTile(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Open-Meteo weather',
                            subtitle: 'Live-feel forecasts on each detail screen.',
                          ),
                          const SizedBox(height: 14),
                          _FeatureTile(
                            icon: Icons.map_outlined,
                            title: 'Maps where supported',
                            subtitle: 'Google Maps on mobile & web with keys · OSM elsewhere.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: () => context.go('/home'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Explore places',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Skip introduction',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCollage extends StatelessWidget {
  const _HeroCollage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -0.09,
              child: _FakeCard(width: 168, hue: Colors.white.withValues(alpha: .18)),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.2, -0.2),
            child: Transform.rotate(
              angle: 0.1,
              child: _FakeCard(width: 152, hue: Colors.white.withValues(alpha: .28)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: math.pi / 36,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .15),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(Icons.flight_takeoff_rounded, size: 44, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _FakeCard extends StatelessWidget {
  const _FakeCard({required this.width, required this.hue});

  final double width;
  final Color hue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: hue,
        border: Border.all(color: Colors.white.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withValues(alpha: .4),
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: 14,
            width: width * .35,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withValues(alpha: .25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground.withValues(alpha: .9) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.primary.withValues(alpha: .08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary.withValues(alpha: .9)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
