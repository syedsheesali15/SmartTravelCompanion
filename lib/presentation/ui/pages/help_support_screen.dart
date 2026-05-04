import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const routePath = '/help';

  static const _items = [
    (
      Icons.explore_outlined,
      'Explore feels empty?',
      'Open Wi‑Fi or mobile data and pull down to refresh on Explore, or '
          'tap Retry on the offline banner. Cached rows still appear when '
          'the device is disconnected.',
    ),
    (
      Icons.cloud_download_outlined,
      'Downloading for offline?',
      'Use Downloaded → “Download / refresh catalog” to merge more '
          'JSONPlaceholder photos into SQLite. Favorites stay available '
          'from the Favorites tab.',
    ),
    (
      Icons.map_outlined,
      'Map or GPS behaving oddly?',
      'Grant location permission and tap the app-bar location icon. '
          'Emulators often fake one global coordinate—use a real device '
          'or set a GPS point inside the emulator for believable distances.',
    ),
    (
      Icons.dark_mode_outlined,
      'Themes',
      'Switch dark mode here in Settings or from the drawer; the choice '
          'is remembered between launches.',
    ),
    (
      Icons.school_outlined,
      'Assignment demos',
      'This build highlights Provider-driven architecture, SQLite caching, '
          'animations (Hero transitions, AnimatedList on Explore), Open‑Meteo '
          'forecast panels, notifications, pagination, Google Maps where '
          'configured, and OSM fallback.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (kIsWeb)
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                leading: Icon(Icons.web_outlined, color: AppColors.primary),
                title: const Text('Web build notes'),
                subtitle: const Text(
                  'Some native-only features (background notifications, full '
                  'Google Maps parity) behave differently—test Android/iOS for '
                  'the complete experience.',
                ),
              ),
            ),
          ..._items.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final icon = e.$1;
            final title = e.$2;
            final body = e.$3;
            return ExpansionTile(
              key: PageStorageKey<int>(i),
              leading: Icon(icon, color: AppColors.primary),
              title:
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding:
                  const EdgeInsets.fromLTRB(72, 0, 24, 16),
              children: [
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                      ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
