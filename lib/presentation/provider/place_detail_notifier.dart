import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/geo/coords_for_place.dart';
import '../../core/geo/predefined_destinations.dart';
import '../../core/geo/haversine_km.dart';
import '../../core/geo/obtain_best_position.dart';
import '../../core/services/notification_service.dart';
import '../../data/datasources/geocoding_remote_datasource.dart';
import '../../domain/entities/geocode_place.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/place_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import 'connectivity_notifier.dart';

enum DetailWeatherPhase { idle, loading, loaded, failure }

final class PlaceDetailNotifier extends ChangeNotifier {
  PlaceDetailNotifier({
    required this.placeId,
    PlaceEntity? initialPlace,
    required PlaceRepository places,
    required WeatherRepository weather,
    required ConnectivityNotifier connectivity,
    required GeocodingRemoteDataSource geocoding,
  }) : _placesRepo = places,
       _weatherRepo = weather,
       _connectivity = connectivity,
       _geocoding = geocoding {
    if (initialPlace != null && initialPlace.id == placeId) {
      _place = initialPlace;
    }
    unawaited(load());
  }

  final int placeId;
  final PlaceRepository _placesRepo;
  final WeatherRepository _weatherRepo;
  final ConnectivityNotifier _connectivity;
  final GeocodingRemoteDataSource _geocoding;

  PlaceEntity? _place;
  WeatherEntity? _weather;
  DetailWeatherPhase _phase = DetailWeatherPhase.idle;
  Object? _weatherError;
  bool _aboutExpanded = false;

  /// Resolved with Open-Meteo geocoding from [PlaceEntity.locationLine] / title (real map pin).
  GeocodePlace? _geocoded;

  /// Distance from device GPS to the resolved location (null if unavailable or denied).
  double? _distanceKm;
  bool _distanceDenied = false;

  PlaceEntity? get place => _place;

  WeatherEntity? get weather => _weather;

  DetailWeatherPhase get weatherPhase => _phase;

  Object? get weatherError => _weatherError;

  bool get aboutExpanded => _aboutExpanded;

  bool get distancePermissionDenied => _distanceDenied;

  double? get distanceKm => _distanceKm;

  GeocodePlace? get geocoded => _geocoded;

  /// Coords for map + weather: curated catalog landmarks → Open‑Meteo geocode → fallback.
  LatLng get mapCoord {
    final line = (_place?.locationLine ?? '').trim();
    final catalog = PredefinedDestinations.tryLatLngForLocationLine(line);
    if (catalog != null) return catalog;
    if (_geocoded != null) {
      return LatLng(_geocoded!.latitude, _geocoded!.longitude);
    }
    final id = _place?.id ?? placeId;
    return latLngForPlaceId(id);
  }

  void toggleAbout() {
    _aboutExpanded = !_aboutExpanded;
    notifyListeners();
  }

  void retryWeather() {
    unawaited(_loadWeather(force: true));
  }

  Future<void> load() async {
    _place = await _placesRepo.getById(placeId);
    notifyListeners();

    await _placesRepo.markRecent(placeId);
    await _reloadPlaceEntity();

    if (_place == null) return;

    if (!_connectivity.offline) {
      await _resolveGeocode();
      await _loadDistanceIfPossible();
    }

    if (_connectivity.offline) {
      _phase = DetailWeatherPhase.failure;
      _weatherError = 'Offline';
      notifyListeners();
      return;
    }
    await _loadWeather(force: false);
  }

  Future<void> _reloadPlaceEntity() async {
    _place = await _placesRepo.getById(placeId);
    notifyListeners();
  }

  Future<void> _resolveGeocode() async {
    final p = _place;
    if (p == null) return;
    if (PredefinedDestinations.tryLatLngForLocationLine(p.locationLine.trim()) !=
        null) {
      _geocoded = null;
      return;
    }
    try {
      final primary = p.locationLine.trim();
      var results = primary.isNotEmpty
          ? await _geocoding.searchByName(primary)
          : <GeocodePlace>[];
      if (results.isEmpty) {
        results = await _geocoding.searchByName(p.title.trim());
      }
      _geocoded = results.isNotEmpty ? results.first : null;
    } catch (_) {
      _geocoded = null;
    }
    notifyListeners();
  }

  Future<void> _loadDistanceIfPossible() async {
    _distanceKm = null;
    _distanceDenied = false;
    if (kIsWeb) {
      notifyListeners();
      return;
    }
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _distanceDenied = true;
        notifyListeners();
        return;
      }

      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        notifyListeners();
        return;
      }

      final pos = await obtainBestGpsPosition();
      if (pos == null) {
        notifyListeners();
        return;
      }
      final dest = mapCoord;
      _distanceKm = haversineKm(
        pos.latitude,
        pos.longitude,
        dest.latitude,
        dest.longitude,
      );
    } catch (_) {
      _distanceKm = null;
    }
    notifyListeners();
  }

  Future<void> _loadWeather({required bool force}) async {
    if (_place == null) return;

    final coord = mapCoord;

    _phase = DetailWeatherPhase.loading;
    _weatherError = null;
    notifyListeners();

    try {
      _weather = await _weatherRepo.fetchCurrent(
        latitude: coord.latitude,
        longitude: coord.longitude,
      );
      _phase = DetailWeatherPhase.loaded;
    } catch (e, _) {
      _weatherError = e;
      _phase = DetailWeatherPhase.failure;
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleFavorite() async {
    if (_place == null) return;
    final next = !_place!.isFavorite;
    await _placesRepo.toggleFavorite(_place!.id, next);
    if (next) {
      await NotificationService.instance.favoriteAdded(_place!.title);
    }
    await _reloadPlaceEntity();
  }
}
