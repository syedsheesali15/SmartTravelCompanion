import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_route_paths.dart';
import '../../../core/router/app_router.dart';
import '../../provider/profile_notifier.dart';
import '../../provider/theme_notifier.dart';

/// Closes the drawer then navigates on the root stack (required for shell + pushed routes).
void navigateFromDrawer(BuildContext context, void Function(GoRouter router) nav) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final root = rootNavigatorKey.currentContext ?? context;
    if (!root.mounted) return;
    nav(GoRouter.of(root));
  });
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final profile = context.watch<ProfileNotifier>();
    final isDark = theme.mode == ThemeMode.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                navigateFromDrawer(context, (r) => r.go(AppRoutePaths.profile));
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 18,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF847CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: profile.avatarImageProvider(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.email,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: .9),
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to edit profile',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: .75),
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _tile(context, Icons.home_outlined, 'Home', () {
                  navigateFromDrawer(context, (r) => r.go(AppRoutePaths.home));
                }),
                _tile(context, Icons.map_outlined, 'Map', () {
                  navigateFromDrawer(context, (r) => r.go(AppRoutePaths.map));
                }),
                _tile(context, Icons.favorite_outline, 'Favorites', () {
                  navigateFromDrawer(
                    context,
                    (r) => r.go(AppRoutePaths.favorites),
                  );
                }),
                _tile(context, Icons.download_outlined, 'Downloaded', () {
                  navigateFromDrawer(context, (r) => r.push(AppRoutePaths.downloads));
                }),
                _tile(context, Icons.settings_outlined, 'Settings', () {
                  navigateFromDrawer(context, (r) => r.push(AppRoutePaths.settings));
                }),
                _tile(context, Icons.help_outline, 'Help & Support', () {
                  navigateFromDrawer(context, (r) => r.push(AppRoutePaths.help));
                }),
                _tile(context, Icons.info_outline, 'About us', () {
                  navigateFromDrawer(context, (r) => r.push(AppRoutePaths.about));
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            minimum: EdgeInsets.zero,
            child: Material(
              color: isDark ? AppColors.darkSurface : Colors.white,
              elevation: 8,
              shadowColor: Colors.black26,
              child: SwitchListTile.adaptive(
                value: isDark,
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
                  color: AppColors.primary,
                ),
                activeThumbColor: AppColors.primary,
                activeTrackColor:
                    AppColors.primary.withValues(alpha: 0.38),
                title: const Text(
                  'Dark mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isDark ? 'Using dark appearance' : 'Using light appearance',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
                onChanged: (v) => theme.setDrawerDarkEnabled(v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary.withValues(alpha: .9)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
