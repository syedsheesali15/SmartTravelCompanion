import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/geo/coords_for_place.dart';
import '../../../../domain/entities/place_entity.dart';

class OpenStreetMapBody extends StatelessWidget {
  const OpenStreetMapBody({
    super.key,
    required this.center,
    required this.markers,
    required this.initialZoom,
  });

  final LatLng center;
  final List<Marker> markers;
  final double initialZoom;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: initialZoom,
        minZoom: 2,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.drag |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.smarttravel.smart_travel_companion',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  /// Build OSM markers (latlong2 types).
  static List<Marker> buildMarkers({
    required bool showAll,
    required List<PlaceEntity> places,
    required double latitude,
    required double longitude,
  }) {
    if (!showAll) {
      return [
        Marker(
          width: 64,
          height: 64,
          point: LatLng(latitude, longitude),
          child: const Icon(Icons.location_pin, color: Colors.redAccent, size: 40),
        ),
      ];
    }
    return places
        .take(80)
        .map(
          (place) => Marker(
            width: 48,
            height: 48,
            point: latLngForPlaceId(place.id),
            child: const Icon(Icons.place, color: Colors.deepPurpleAccent),
          ),
        )
        .toList(growable: false);
  }

  static LatLng computeCenter({
    required bool showAll,
    required List<PlaceEntity> places,
    required double latitude,
    required double longitude,
  }) {
    if (!showAll) return LatLng(latitude, longitude);
    if (places.isEmpty) return const LatLng(12, 101);
    var lat = 0.0;
    var lng = 0.0;
    for (final place in places) {
      final point = latLngForPlaceId(place.id);
      lat += point.latitude;
      lng += point.longitude;
    }
    lat /= places.length;
    lng /= places.length;
    return LatLng(lat, lng);
  }

  static double zoomFor(bool showAll) => showAll ? 3 : 11;
}
