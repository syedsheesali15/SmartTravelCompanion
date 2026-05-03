import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../provider/theme_notifier.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final isDark = theme.mode == ThemeMode.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 18, 20, 24),
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
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/200?img=12'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aarav Mehta',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'aarav.explorer@example.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: .9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _tile(context, Icons.home_outlined, 'Home', () {
                  Navigator.of(context).maybePop();
                  context.go('/home');
                }),
                _tile(context, Icons.map_outlined, 'Map', () {
                  Navigator.of(context).maybePop();
                  context.go('/map');
                }),
                _tile(context, Icons.favorite_outline, 'Favorites', () {
                  Navigator.of(context).maybePop();
                  context.go('/favorites');
                }),
                _tile(context, Icons.download_outlined, 'Downloaded', () {
                  Navigator.of(context).maybePop();
                  context.push('/downloads');
                }),
                _tile(context, Icons.settings_outlined, 'Settings', () {
                  Navigator.of(context).maybePop();
                  context.push('/settings');
                }),
                _tile(context, Icons.help_outline, 'Help & Support', () {
                  Navigator.of(context).maybePop();
                  context.push('/help');
                }),
                _tile(context, Icons.info_outline, 'About us', () {
                  Navigator.of(context).maybePop();
                  context.push('/about');
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
                activeTrackColor: AppColors.primary.withValues(alpha: 0.38),
                title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary.withValues(alpha: .9)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
