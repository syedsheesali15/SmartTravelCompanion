import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_navigation.dart';
import '../../../data/datasources/geocoding_remote_datasource.dart';
import '../../../domain/entities/place_entity.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../domain/repositories/place_repository.dart';
import '../../../domain/repositories/weather_repository.dart';
import '../../provider/connectivity_notifier.dart';
import '../../provider/place_detail_notifier.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.placeId,
    this.initialPlace,
  });

  final int placeId;
  final PlaceEntity? initialPlace;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PlaceDetailNotifier(
        placeId: placeId,
        initialPlace: initialPlace,
        places: ctx.read<PlaceRepository>(),
        weather: ctx.read<WeatherRepository>(),
        connectivity: ctx.read<ConnectivityNotifier>(),
        geocoding: ctx.read<GeocodingRemoteDataSource>(),
      ),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PlaceDetailNotifier>();
    final place = notifier.place;

    if (place == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final coord = notifier.mapCoord;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                onPressed: notifier.toggleFavorite,
                icon: Icon(
                  place.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: place.isFavorite ? AppColors.accentHeart : null,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'place-${place.id}',
                child: CachedNetworkImage(
                  imageUrl: place.fullImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  place.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 20,
                      color: AppColors.primary.withValues(alpha: .85),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        place.locationLine,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (notifier.distanceKm != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        size: 18,
                        color: AppColors.primary.withValues(alpha: .9),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '~${notifier.distanceKm!.round()} km from your location',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ] else if (notifier.distancePermissionDenied) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Allow location access in settings to see distance from you.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  place.aboutText,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current weather',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: .92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flash_on_rounded,
                            size: 15,
                            color: Colors.white.withValues(alpha: .95),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Live',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _WeatherPanel(
                    key: ValueKey(notifier.weatherPhase),
                    phase: notifier.weatherPhase,
                    snapshot: notifier.weather,
                    error: notifier.weatherError,
                    onRetry: notifier.retryWeather,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: notifier.toggleAbout,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'About the place',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Icon(
                        notifier.aboutExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.hardEdge,
                  child: Text(
                    place.aboutText,
                    maxLines: notifier.aboutExpanded ? null : 3,
                    overflow: notifier.aboutExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () {
            context.pushMapTarget(
              lat: coord.latitude,
              lng: coord.longitude,
              title: place.title,
            );
          },
          icon: const Icon(Icons.map_rounded),
          label: const Text('View on map'),
        ),
      ),
    );
  }
}

class _WeatherPanel extends StatelessWidget {
  const _WeatherPanel({
    super.key,
    required this.phase,
    required this.snapshot,
    required this.error,
    required this.onRetry,
  });

  final DetailWeatherPhase phase;
  final WeatherEntity? snapshot;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case DetailWeatherPhase.loading:
      case DetailWeatherPhase.idle:
        return const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        );
      case DetailWeatherPhase.failure:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather unavailable (${error ?? 'retry'})'),
            TextButton(onPressed: onRetry, child: const Text('Retry weather')),
          ],
        );
      case DetailWeatherPhase.loaded:
        final w = snapshot;
        if (w == null) {
          return const SizedBox.shrink();
        }
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${w.temperatureC.toStringAsFixed(1)} °C',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            w.conditionLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.warning.withValues(alpha: .2),
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        color: AppColors.warning.withValues(alpha: .95),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text('Humidity • ${w.humidityPct}%'),
                Text('Wind • ${w.windKmh.toStringAsFixed(1)} km/h'),
                Text('Feels like • ${w.apparentC.toStringAsFixed(1)} °C'),
              ],
            ),
          ),
        );
    }
  }
}
