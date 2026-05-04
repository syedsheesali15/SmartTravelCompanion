import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Matches `pubspec.yaml` version for the store string.
const _kAppVersion = '1.0.0+1';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routePath = '/about';

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.flight_takeoff_rounded, size: 56, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Smart Travel Companion',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text('Version $_kAppVersion', style: body),
          const SizedBox(height: 24),
          Text(
            'Built for the SMD capstone: layered clean architecture, '
            'SQLite-backed catalog, responsive UI, and optional Google Maps.',
            style: body?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 20),
          Text(
            'Attribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Map tiles from OpenStreetMap when Google Maps is not active. '
            'Map data © OpenStreetMap contributors. '
            'See https://www.openstreetmap.org/copyright',
            style: body?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 20),
          Text(
            'Third-party data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Place listings use JSONPlaceholder sample photos. Weather uses '
            'Open‑Meteo public APIs. Geocoding uses the project’s remote '
            'geocoding source configured in code.',
            style: body?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
