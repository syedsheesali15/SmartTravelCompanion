import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/geocode_place.dart';
import '../../domain/entities/place_entity.dart';
import 'app_route_paths.dart';

extension AppNavigation on BuildContext {
  /// Catalog detail with [Hero] continuity — passes [PlaceEntity] as `extra` (same isolate).
  void pushPlaceDetail(PlaceEntity place) {
    GoRouter.of(this).push(
      AppRoutePaths.placeDetail(place.id),
      extra: place,
    );
  }

  void pushWorldPlacePreview({
    required double latitude,
    required double longitude,
    required String title,
    required String subtitle,
    required int geocodeSeedId,
  }) {
    GoRouter.of(this).push(
      '${AppRoutePaths.worldPlace}'
      '${AppRoutePaths.worldPlaceQuery(
            lat: latitude,
            lng: longitude,
            title: title,
            subtitle: subtitle,
            geocodeSeedId: geocodeSeedId,
          )}',
    );
  }

  void pushWorldPlaceFromGeocode(GeocodePlace p) {
    pushWorldPlacePreview(
      latitude: p.latitude,
      longitude: p.longitude,
      title: p.name,
      subtitle: p.subtitle,
      geocodeSeedId: p.id,
    );
  }

  void pushMapTarget({
    required double lat,
    required double lng,
    required String title,
  }) {
    GoRouter.of(this).push(
      '${AppRoutePaths.mapTarget}'
      '${AppRoutePaths.mapTargetQuery(lat: lat, lng: lng, title: title)}',
    );
  }
}
