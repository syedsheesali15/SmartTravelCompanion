import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/maps_secrets.dart';
import '../../../../core/geo/english_place_description.dart';
import '../../../../core/geo/haversine_km.dart';
import '../../../../core/geo/obtain_best_position.dart';
import '../../../../core/maps/maps_capabilities.dart';
import '../../../../data/datasources/geocoding_remote_datasource.dart';
import '../../../domain/entities/geocode_place.dart';
import '../../../domain/entities/place_entity.dart';
import '../../../domain/entities/place_query.dart';
import '../../../domain/entities/placeholder_photo.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../domain/repositories/place_repository.dart';
import '../../../domain/repositories/weather_repository.dart';
import '../../provider/places_notifier.dart';
import 'google_maps_body.dart';
import 'open_street_map_body.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.showAll,
    this.latitude,
    this.longitude,
    this.caption,
  });

  final bool showAll;
  final double? latitude;
  final double? longitude;
  final String? caption;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  Timer? _debounce;
  bool _suggestLoading = false;
  List<GeocodePlace> _suggestions = const [];
  String? _suggestError;

  double? _searchLat;
  double? _searchLng;
  String? _searchLabel;
  String _searchLocationLine = '';

  WeatherEntity? _weather;
  PlaceholderPhoto? _spotlightPhoto;
  bool _spotlightLoading = false;

  double? _myLat;
  double? _myLng;
  bool _locatingSelf = false;
  bool _locationDenied = false;

  /// Do not recreate this [Future] on every [setState] — [FutureBuilder] would
  /// return to `waiting`, swap in the loading scaffold, dispose the search field,
  /// and the soft keyboard disappears after each keystroke.
  Future<List<PlaceEntity>>? _cachedMapCatalogFuture;
  String _cachedMapCatalogKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _updateMyLocation();
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) await _updateMyLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _mapController.dispose();
    _queryController.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !kIsWeb) {
      unawaited(_updateMyLocation());
    }
  }

  bool _preferGoogleMaps() {
    if (!MapsCapabilities.sdkRunsGoogleMaps) return false;
    if (kIsWeb) return MapsSecrets.googleMapsDartDefineProvided;
    return MapsSecrets.useGoogleMapsNative;
  }

  Future<void> _updateMyLocation() async {
    if (kIsWeb) return;
    if (!mounted) return;
    setState(() {
      _locatingSelf = true;
      _locationDenied = false;
    });
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationDenied = true;
            _locatingSelf = false;
          });
        }
        return;
      }
      final servicesOn = await Geolocator.isLocationServiceEnabled();
      if (!servicesOn) {
        if (mounted) setState(() => _locatingSelf = false);
        return;
      }
      final pos = await obtainBestGpsPosition();
      if (!mounted) return;
      if (pos == null) {
        setState(() => _locatingSelf = false);
        return;
      }
      setState(() {
        _myLat = pos.latitude;
        _myLng = pos.longitude;
        _locatingSelf = false;
        _locationDenied = false;
      });
    } catch (_) {
      if (mounted) setState(() => _locatingSelf = false);
    }
  }

  /// When huge, GPS is often the Android / iOS simulator default (e.g. US) not the user’s city.
  bool get _distanceLooksLikeWrongGps =>
      _kmToTarget != null && _kmToTarget! > 3500;

  double? get _targetPinLat {
    if (_searchLat != null && _searchLng != null) return _searchLat;
    if (!widget.showAll &&
        widget.latitude != null &&
        widget.longitude != null) {
      return widget.latitude;
    }
    return null;
  }

  double? get _targetPinLng {
    if (_searchLat != null && _searchLng != null) return _searchLng;
    if (!widget.showAll &&
        widget.latitude != null &&
        widget.longitude != null) {
      return widget.longitude;
    }
    return null;
  }

  double? get _kmToTarget {
    if (kIsWeb || _myLat == null || _myLng == null) return null;
    final tLat = _targetPinLat;
    final tLng = _targetPinLng;
    if (tLat == null || tLng == null) return null;
    return haversineKm(_myLat!, _myLng!, tLat, tLng);
  }

  void _onQueryChanged(String raw) {
    _debounce?.cancel();
    final q = raw.trim();
    if (q.length < 2) {
      setState(() {
        _suggestions = const [];
        _suggestError = null;
        _suggestLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 420), () async {
      setState(() {
        _suggestLoading = true;
        _suggestError = null;
      });
      try {
        final geo = context.read<GeocodingRemoteDataSource>();
        final list = await geo.searchByName(q);
        if (!mounted) return;
        setState(() {
          _suggestions = list;
          _suggestLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _suggestions = const [];
          _suggestLoading = false;
          _suggestError = '$e';
        });
      }
    });
  }

  int _jsonPlaceholderPhotoId(GeocodePlace place) =>
      (place.id.abs() % 5000) + 1;

  Future<void> _selectGeocode(GeocodePlace place) async {
    setState(() {
      _queryFocus.unfocus();
      _suggestions = const [];
      _searchLat = place.latitude;
      _searchLng = place.longitude;
      _searchLabel = place.name;
      _searchLocationLine = place.subtitle;

      _weather = null;
      _spotlightPhoto = null;
      _spotlightLoading = true;
      _suggestError = null;
    });

    if (!_preferGoogleMaps()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(LatLng(place.latitude, place.longitude), 13);
      });
    }

    final weatherRepo = context.read<WeatherRepository>();
    final placeRepo = context.read<PlaceRepository>();

    try {
      final results = await Future.wait([
        weatherRepo.fetchCurrent(
          latitude: place.latitude,
          longitude: place.longitude,
        ),
        placeRepo.fetchPlaceholderPhoto(_jsonPlaceholderPhotoId(place)),
      ]);
      if (!mounted) return;
      final weather = results[0] as WeatherEntity;
      final photo = results[1] as PlaceholderPhoto;
      setState(() {
        _weather = weather;
        _spotlightPhoto = photo;
        _spotlightLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _spotlightLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load details: $e')));
    }
  }

  void _clearSpotlight() {
    setState(() {
      _searchLat = null;
      _searchLng = null;
      _searchLabel = null;
      _searchLocationLine = '';
      _weather = null;
      _spotlightPhoto = null;
      _spotlightLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final refreshSalt = context.select<PlacesNotifier, int>(
      (n) => n.refreshCounter,
    );
    final repo = context.read<PlaceRepository>();
    final useGoogle = _preferGoogleMaps();

    final catalogKey =
        '$refreshSalt-${widget.showAll ? 'browse' : 'pin'}';
    if (_cachedMapCatalogFuture == null ||
        _cachedMapCatalogKey != catalogKey) {
      _cachedMapCatalogKey = catalogKey;
      _cachedMapCatalogFuture = repo.queryLocal(PlaceQuery.initial);
    }

    return FutureBuilder<List<PlaceEntity>>(
      future: _cachedMapCatalogFuture,
      builder: (context, snapshot) {
        final appBar = AppBar(
          title: Text(
            widget.showAll ? 'Pinned adventures' : (widget.caption ?? 'Map'),
          ),
          actions: [
            if (!kIsWeb)
              IconButton(
                tooltip: 'Where I am (GPS)',
                icon: _locatingSelf
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
                onPressed: _locatingSelf ? null : _updateMyLocation,
              ),
          ],
        );

        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: appBar,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: appBar,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load cached places:\n${snapshot.error}'),
              ),
            ),
          );
        }

        final catalog = snapshot.data ?? const <PlaceEntity>[];
        final pinList = widget.showAll ? catalog : const <PlaceEntity>[];

        final lat = widget.latitude ?? 0;
        final lng = widget.longitude ?? 0;
        final fallbackCenter = OpenStreetMapBody.computeCenter(
          showAll: widget.showAll,
          places: catalog,
          latitude: lat,
          longitude: lng,
        );
        final fallbackMarkers = OpenStreetMapBody.buildMarkers(
          showAll: widget.showAll,
          places: catalog,
          latitude: lat,
          longitude: lng,
        );
        final fallbackZoom = OpenStreetMapBody.zoomFor(widget.showAll);

        final pinLat = _targetPinLat;
        final pinLng = _targetPinLng;
        final mapCenter = (pinLat != null && pinLng != null)
            ? LatLng(pinLat, pinLng)
            : fallbackCenter;
        final mapZoom = (pinLat != null && pinLng != null)
            ? 13.0
            : fallbackZoom;

        final searchOverlays = (_searchLat != null && _searchLng != null)
            ? <Marker>[
                Marker(
                  width: 56,
                  height: 56,
                  point: LatLng(_searchLat!, _searchLng!),
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.deepOrange,
                    size: 46,
                  ),
                ),
              ]
            : const <Marker>[];

        return Scaffold(
          appBar: appBar,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _queryController,
                        focusNode: _queryFocus,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          hintText: 'Search any place worldwide…',
                          prefixIcon: const Icon(Icons.travel_explore_outlined),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_spotlightLoading)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              if (_queryController.text.isNotEmpty)
                                IconButton(
                                  tooltip: 'Clear',
                                  onPressed: () {
                                    _queryController.clear();
                                    _clearSpotlight();
                                    setState(() {
                                      _suggestions = const [];
                                      _suggestError = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {});
                          _onQueryChanged(v);
                        },
                        onSubmitted: (_) => _queryFocus.unfocus(),
                      ),
                      if (_suggestLoading)
                        const LinearProgressIndicator(minHeight: 2),
                      if (_suggestError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _suggestError!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      if (_suggestions.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Material(
                            color: Theme.of(context).colorScheme.surface,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 220),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _suggestions.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final p = _suggestions[i];
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text(p.name),
                                    subtitle: Text(
                                      p.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => _selectGeocode(p),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: useGoogle
                          ? GoogleMapsBody(
                              showAll: widget.showAll,
                              places: pinList,
                              singleLat: widget.latitude,
                              singleLng: widget.longitude,
                              markerTitle: widget.caption ?? 'Pinned place',
                              searchLat: _searchLat,
                              searchLng: _searchLng,
                              searchTitle: _searchLabel,
                              deviceLat: _myLat,
                              deviceLng: _myLng,
                            )
                          : OpenStreetMapBody(
                              mapController: _mapController,
                              center: mapCenter,
                              markers: fallbackMarkers,
                              initialZoom: mapZoom,
                              overlayMarkers: searchOverlays,
                              myLocation: _myLat != null && _myLng != null
                                  ? LatLng(_myLat!, _myLng!)
                                  : null,
                              lineEnd: pinLat != null && pinLng != null
                                  ? LatLng(pinLat, pinLng)
                                  : null,
                            ),
                    ),
                    if (pinLat != null && pinLng != null)
                      Positioned(
                        left: 10,
                        right: 10,
                        top: 8,
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh
                              .withValues(alpha: 0.95),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.alt_route_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: kIsWeb
                                      ? const Text(
                                          'GPS distance & “my location” work on Android / iOS builds.',
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _kmToTarget != null
                                                  ? '~${_kmToTarget!.round()} km from you (straight line, as the crow flies)'
                                                  : _locatingSelf
                                                  ? 'Finding your GPS position…'
                                                  : _locationDenied
                                                  ? 'Allow location access to see distance from you.'
                                                  : 'Tap the location icon in the app bar to refresh GPS.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            if (_distanceLooksLikeWrongGps &&
                                                _kmToTarget != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  'This distance usually means your device is not using GPS near '
                                                  'the pin (common on emulators: they default to the US). '
                                                  'Android Emulator → ⋮ → Location → set a point near your place, '
                                                  'or use a real phone with GPS on.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                        fontSize: 11.5,
                                                        height: 1.35,
                                                      ),
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
                    if (_weather != null || _spotlightPhoto != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Material(
                            elevation: 4,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_spotlightPhoto != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _spotlightPhoto!.imageUrl,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 88,
                                                  height: 88,
                                                  color: Colors.black12,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.broken_image_outlined,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  if (_spotlightPhoto != null)
                                    const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _searchLabel ?? 'Place',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        if (_searchLabel != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            englishBlurbForGeocodedPlace(
                                              placeName: _searchLabel!,
                                              locationLine: _searchLocationLine,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(height: 1.35),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (_spotlightPhoto != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Illustrative photo only.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                        if (_weather != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            '${_weather!.temperatureC.toStringAsFixed(0)}°C · ${_weather!.conditionLabel}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                          Text(
                                            'Feels ${_weather!.apparentC.toStringAsFixed(0)}° · '
                                            'Humidity ${_weather!.humidityPct}% · Wind ${_weather!.windKmh.toStringAsFixed(0)} km/h',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
