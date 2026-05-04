import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/maps_secrets.dart';
import '../../../core/router/app_route_paths.dart';
import '../../provider/places_notifier.dart';
import '../../provider/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routePath = AppRoutePaths.settings;

  String _mapBackendLabel() {
    if (kIsWeb) {
      return MapsSecrets.googleMapsDartDefineProvided
          ? 'Web: Google Maps (API key supplied at build time)'
          : 'Web: OpenStreetMap tiles';
    }
    return MapsSecrets.useGoogleMapsNative
        ? 'Device: native Google Maps (USE_GOOGLE_MAPS dart-define)'
        : 'Device: OpenStreetMap (no Google Billing required)';
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final dark = themeNotifier.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionTitle(context, 'Appearance'),
          SwitchListTile(
            secondary: Icon(Icons.dark_mode_outlined, color: AppColors.primary),
            title: const Text('Dark theme'),
            subtitle: const Text(
              'Applies instantly app-wide—the same toggle lives in the drawer.',
            ),
            value: dark,
            onChanged: (v) => themeNotifier.setDrawerDarkEnabled(v),
          ),
          const Divider(height: 1),
          _sectionTitle(context, 'Navigation'),
          ListTile(
            leading: Icon(Icons.explore_outlined, color: AppColors.primary),
            title: const Text('Explore'),
            subtitle: const Text('Browse the photo catalog and chips'),
            onTap: () => context.go(AppRoutePaths.home),
          ),
          ListTile(
            leading: Icon(Icons.map_outlined, color: AppColors.primary),
            title: const Text('Map'),
            subtitle: const Text('World view and pinned searches'),
            onTap: () => context.go(AppRoutePaths.map),
          ),
          ListTile(
            leading:
                Icon(Icons.person_outline_rounded, color: AppColors.primary),
            title: const Text('Profile'),
            subtitle: const Text('Avatar and display name'),
            onTap: () => context.go(AppRoutePaths.profile),
          ),
          ListTile(
            leading: Icon(Icons.download_outlined, color: AppColors.primary),
            title: const Text('Offline catalog'),
            subtitle: const Text('Cache size and refresh'),
            onTap: () => context.push(AppRoutePaths.downloads),
          ),
          const Divider(height: 1),
          _sectionTitle(context, 'Data'),
          ListTile(
            leading: Icon(Icons.refresh_rounded, color: AppColors.primary),
            title: const Text('Refresh Explore now'),
            subtitle: const Text('Pull JSONPlaceholder batches into SQLite'),
            onTap: () async {
              await context.read<PlacesNotifier>().refreshPull();
              if (!context.mounted) return;
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('Explore data refreshed.')),
              );
            },
          ),
          const Divider(height: 1),
          _sectionTitle(context, 'Maps'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mapBackendLabel(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'OpenStreetMap data © OpenStreetMap contributors '
                  '(see About for the full notice).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
      ),
    );
  }
}
