import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../provider/theme_notifier.dart';
import '../filters/filter_sheet.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _openBranch(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeNotifier>().mode;

    return ScaffoldMessenger(
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: themeMode == ThemeMode.dark ? 10 : 6,
              shape: const CircleBorder(),
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const FilterSheet(),
                );
              },
              child: const Icon(Icons.add, size: 30),
            ),
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: themeMode == ThemeMode.dark ? .45 : .08,
                ),
                blurRadius: 18,
              ),
            ],
          ),
          child: BottomAppBar(
            notchMargin: 10,
            shape: const CircularNotchedRectangle(),
            color: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  _NavChip(
                    selected: navigationShell.currentIndex == 0,
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => _openBranch(0),
                  ),
                  _NavChip(
                    selected: navigationShell.currentIndex == 1,
                    icon: Icons.map_outlined,
                    label: 'Map',
                    onTap: () => _openBranch(1),
                  ),
                  const SizedBox(width: 72),
                  _NavChip(
                    selected: navigationShell.currentIndex == 2,
                    icon: Icons.favorite_outline,
                    label: 'Favorites',
                    onTap: () => _openBranch(2),
                  ),
                  _NavChip(
                    selected: navigationShell.currentIndex == 3,
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () => _openBranch(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    /// Kit: selected = purple accent; inactive = cool grey (#94A3B8).
    final active = AppColors.primary;
    final inactive = const Color(0xFF94A3B8);
    final fg = selected ? active : inactive;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: fg),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: fg,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 11,
                        letterSpacing: 0.1,
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
