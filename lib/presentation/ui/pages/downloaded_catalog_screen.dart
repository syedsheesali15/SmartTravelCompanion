import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_route_paths.dart';
import '../../../domain/repositories/place_repository.dart';
import '../../provider/places_notifier.dart';

/// Offline-ready catalog backed by SQLite (JSONPlaceholder previews).
class DownloadedCatalogScreen extends StatefulWidget {
  const DownloadedCatalogScreen({super.key});

  static const routePath = AppRoutePaths.downloads;

  @override
  State<DownloadedCatalogScreen> createState() =>
      _DownloadedCatalogScreenState();
}

class _DownloadedCatalogScreenState extends State<DownloadedCatalogScreen> {
  int _reloadKey = 0;

  Future<void> _pullRefresh() async {
    await context.read<PlacesNotifier>().refreshPull();
    if (!mounted) return;
    setState(() => _reloadKey++);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      const SnackBar(content: Text('Catalog refreshed from the server.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PlaceRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          FutureBuilder<int>(
            key: ValueKey(_reloadKey),
            future: repo.countCachedCatalogPlaces(),
            builder: (context, snap) {
              final count = snap.data;
              final loading = snap.connectionState != ConnectionState.done;
              return ListTile(
                leading: Icon(Icons.storage_outlined, color: AppColors.primary),
                title: const Text('Place catalog cache'),
                subtitle: Text(
                  loading
                      ? 'Reading local database…'
                      : '$count photos merged into SQLite for offline thumbnails and Explore.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading:
                Icon(Icons.star_outline_rounded, color: AppColors.primary),
            title: const Text('Favorites & recents'),
            subtitle: Text(
              'Star places from Explore—the list is stored locally and survives restarts.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => context.go(AppRoutePaths.favorites),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () async => _pullRefresh(),
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Download / refresh catalog'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutePaths.home),
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Open Explore'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
