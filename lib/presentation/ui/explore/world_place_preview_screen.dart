import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/geo/english_place_description.dart';
import '../../../core/geo/haversine_km.dart';
import '../../../core/geo/obtain_best_position.dart';
import '../../../domain/entities/place_entity.dart';
import '../../../domain/entities/placeholder_photo.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../domain/repositories/place_repository.dart';
import '../../../domain/repositories/weather_repository.dart';
import '../../provider/places_notifier.dart';

/// Same layout as [DetailScreen] (Barcelona): hero image, heart, location, distance,
/// description, weather + Live, About accordion, View on map.
class WorldPlacePreviewScreen extends StatefulWidget {
  const WorldPlacePreviewScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.subtitle,
    required this.geocodeSeedId,
  });

  final double latitude;
  final double longitude;
  final String title;
  final String subtitle;
  final int geocodeSeedId;

  @override
  State<WorldPlacePreviewScreen> createState() =>
      _WorldPlacePreviewScreenState();
}

class _WorldPlacePreviewScreenState extends State<WorldPlacePreviewScreen> {
  bool _loading = true;
  Object? _error;
  WeatherEntity? _weather;
  PlaceholderPhoto? _photo;

  bool _aboutExpanded = false;
  bool _isFavorite = false;

  double? _distanceKm;
  bool _distanceDenied = false;

  String get _aboutText => englishBlurbForGeocodedPlace(
    placeName: widget.title,
    locationLine: widget.subtitle,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  PlaceEntity _worldProjectionForFavorite({
    PlaceholderPhoto? photo,
    required bool favored,
  }) {
    final imageUrl = photo?.imageUrl ?? '';
    final loc = widget.subtitle.isNotEmpty ? widget.subtitle : widget.title;
    return PlaceEntity(
      id: 0,
      albumId: 0,
      title: widget.title,
      fullImageUrl: imageUrl,
      thumbnailUrl: imageUrl,
      locationLine: loc,
      aboutText: _aboutText,
      regionBucket: 'World',
      isFavorite: favored,
      lastViewedMs: null,
      worldLatitude: widget.latitude,
      worldLongitude: widget.longitude,
      worldGeocodeSeedId: widget.geocodeSeedId,
    );
  }

  Future<void> _readFavorite(PlaceRepository placeRepo) async {
    final fav = await placeRepo.isWorldPlaceFavorite(
      widget.latitude,
      widget.longitude,
    );
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final photo = _photo;
    final next = !_isFavorite;
    final placeRepo = context.read<PlaceRepository>();
    await placeRepo.setWorldPlaceFavorite(
      projection: _worldProjectionForFavorite(photo: photo, favored: next),
      favorite: next,
    );
    if (next && mounted) {
      await NotificationService.instance.favoriteAdded(widget.title);
    }
    if (!mounted) return;
    setState(() => _isFavorite = next);
    await context.read<PlacesNotifier>().refreshPlaces();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final weatherRepo = context.read<WeatherRepository>();
    final placeRepo = context.read<PlaceRepository>();
    final photoId = (widget.geocodeSeedId.abs() % 5000) + 1;
    try {
      final results = await Future.wait([
        weatherRepo.fetchCurrent(
          latitude: widget.latitude,
          longitude: widget.longitude,
        ),
        placeRepo.fetchPlaceholderPhoto(photoId),
      ]);
      if (!mounted) return;
      setState(() {
        _weather = results[0] as WeatherEntity;
        _photo = results[1] as PlaceholderPhoto;
        _loading = false;
      });
      await _readFavorite(placeRepo);
      final p = _photo!;
      await placeRepo.recordWorldPlaceVisited(
        latitude: widget.latitude,
        longitude: widget.longitude,
        title: widget.title,
        subtitle: widget.subtitle.isNotEmpty ? widget.subtitle : widget.title,
        geocodeSeedId: widget.geocodeSeedId,
        thumbnailUrl: p.imageUrl,
        fullImageUrl: p.imageUrl,
        aboutText: _aboutText,
      );
      if (mounted) await context.read<PlacesNotifier>().refreshPlaces();
      await _loadDistance();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadDistance() async {
    if (kIsWeb) return;
    _distanceKm = null;
    _distanceDenied = false;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _distanceDenied = true);
        return;
      }
      final on = await Geolocator.isLocationServiceEnabled();
      if (!on) return;

      final pos = await obtainBestGpsPosition();
      if (!mounted || pos == null) return;
      setState(() {
        _distanceKm = haversineKm(
          pos.latitude,
          pos.longitude,
          widget.latitude,
          widget.longitude,
        );
        _distanceDenied = false;
      });
    } catch (_) {
      /* leave distance hidden */
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load details: $_error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final imageUrl = _photo?.imageUrl;

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
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.accentHeart : null,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'world-place-${widget.geocodeSeedId}',
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 56,
                          ),
                        ),
                      )
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined, size: 56),
                      ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.title,
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
                        widget.subtitle.isNotEmpty
                            ? widget.subtitle
                            : widget.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_distanceKm != null) ...[
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
                          '~${_distanceKm!.round()} km from your location',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ] else if (_distanceDenied) ...[
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
                  _aboutText,
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
                if (_weather != null)
                  Card(
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
                                      '${_weather!.temperatureC.toStringAsFixed(1)} °C',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                    Text(
                                      _weather!.conditionLabel,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: AppColors.warning.withValues(
                                  alpha: .2,
                                ),
                                child: Icon(
                                  Icons.wb_sunny_rounded,
                                  color: AppColors.warning.withValues(
                                    alpha: .95,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text('Humidity • ${_weather!.humidityPct}%'),
                          Text(
                            'Wind • ${_weather!.windKmh.toStringAsFixed(1)} km/h',
                          ),
                          Text(
                            'Feels like • ${_weather!.apparentC.toStringAsFixed(1)} °C',
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => setState(() => _aboutExpanded = !_aboutExpanded),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'About the place',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Icon(
                        _aboutExpanded ? Icons.expand_less : Icons.expand_more,
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
                    _aboutText,
                    maxLines: _aboutExpanded ? null : 3,
                    overflow: _aboutExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
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
              lat: widget.latitude,
              lng: widget.longitude,
              title: widget.title,
            );
          },
          icon: const Icon(Icons.map_rounded),
          label: const Text('View on map'),
        ),
      ),
    );
  }
}
