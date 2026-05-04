import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_route_paths.dart';

import '../widgets/app_brand_icon.dart';

/// Welcome / onboarding — dark hero with core features list (full-screen / edge-to-edge).
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  static const routePath = AppRoutePaths.landing;

  static const _accentPurple = Color(0xFFB8A9FF);
  static const _featureIconBg = Color(0xFF1E293B);
  static const _gradientBottom = Color(0xFF020617);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(_kLandingOverlayStyle);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kLandingOverlayStyle,
      child: Scaffold(
        backgroundColor: LandingScreen._gradientBottom,
        resizeToAvoidBottomInset: false,
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F172A),
                  LandingScreen._gradientBottom,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      8,
                      24,
                      120 + bottomInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.go(AppRoutePaths.home),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: .08),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const AppBrandIcon(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    color: Colors.white,
                                  ),
                              children: [
                                const TextSpan(text: 'Smart '),
                                TextSpan(
                                  text: 'Travel',
                                  style: TextStyle(
                                    color: LandingScreen._accentPurple,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(text: ' Companion'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your ultimate travel guide to explore beautiful places, '
                      'check real-time weather and manage your favorites.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: .88),
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 22),
                    Divider(
                      color: Colors.white.withValues(alpha: .14),
                      height: 1,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CORE FEATURES',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: LandingScreen._accentPurple,
                          ),
                    ),
                    const SizedBox(height: 18),
                    const _CoreFeatureRow(
                      icon: Icons.location_on_rounded,
                      label: 'Explore beautiful places',
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    const _CoreFeatureRow(
                      icon: Icons.wb_cloudy_rounded,
                      label: 'Real-time weather updates',
                      iconColor: Color(0xFF93C5FD),
                    ),
                    const SizedBox(height: 14),
                    const _CoreFeatureRow(
                      icon: Icons.search_rounded,
                      label: 'Search & filter places',
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    const _CoreFeatureRow(
                      icon: Icons.favorite_rounded,
                      label: 'Save your favorite places',
                      iconColor: AppColors.accentHeart,
                    ),
                    const SizedBox(height: 14),
                    const _CoreFeatureRow(
                      icon: Icons.download_for_offline_rounded,
                      label: 'Offline support & caching',
                      iconColor: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 14),
                    const _CoreFeatureRow(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Smooth animations & transitions',
                      iconColor: Color(0xFFFBBF24),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: bottomInset + 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => context.go(AppRoutePaths.home),
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
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    ),
    );
  }
}

const SystemUiOverlayStyle _kLandingOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0xFF020617),
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarContrastEnforced: false,
);

class _CoreFeatureRow extends StatelessWidget {
  const _CoreFeatureRow({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: LandingScreen._featureIconBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: .06),
            ),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: .94),
                  height: 1.25,
                ),
          ),
        ),
      ],
    );
  }
}
