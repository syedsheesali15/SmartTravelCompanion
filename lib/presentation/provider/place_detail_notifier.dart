import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/geo/coords_for_place.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/place_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import 'connectivity_notifier.dart';

enum DetailWeatherPhase { idle, loading, loaded, failure }

final class PlaceDetailNotifier extends ChangeNotifier {
  PlaceDetailNotifier({
    required this.placeId,
    required PlaceRepository places,
    required WeatherRepository weather,
    required ConnectivityNotifier connectivity,
  }) : _placesRepo = places,
       _weatherRepo = weather,
       _connectivity = connectivity {
    unawaited(load());
  }

  final int placeId;
  final PlaceRepository _placesRepo;
  final WeatherRepository _weatherRepo;
  final ConnectivityNotifier _connectivity;

  PlaceEntity? _place;
  WeatherEntity? _weather;
  DetailWeatherPhase _phase = DetailWeatherPhase.idle;
  Object? _weatherError;
  bool _aboutExpanded = false;

  PlaceEntity? get place => _place;

  WeatherEntity? get weather => _weather;

  DetailWeatherPhase get weatherPhase => _phase;

  Object? get weatherError => _weatherError;

  bool get aboutExpanded => _aboutExpanded;

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

    if (_connectivity.offline || _place == null) {
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

  Future<void> _loadWeather({required bool force}) async {
    if (_place == null) return;

    final coord = latLngForPlaceId(_place!.id);

    _phase = DetailWeatherPhase.loading;
    _weatherError = null;
    notifyListeners();

    try {
      _weather =
          await _weatherRepo.fetchCurrent(latitude: coord.latitude, longitude: coord.longitude);
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
