import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/geo/coords_for_place.dart';
import '../../../../domain/entities/place_entity.dart';

class OpenStreetMapBody extends StatelessWidget {
  const OpenStreetMapBody({
    super.key,
    required this.mapController,
    required this.center,
    required this.markers,
    required this.initialZoom,
    this.overlayMarkers = const [],
    this.myLocation,
    this.lineEnd,
  });

  final MapController mapController;
  final LatLng center;
  final List<Marker> markers;
  final List<Marker> overlayMarkers;
  final double initialZoom;

  /// Device GPS — blue dot on top of the stack.
  final LatLng? myLocation;

  /// Straight line is drawn from [myLocation] to [lineEnd] when both are set.
  final LatLng? lineEnd;

  @override
  Widget build(BuildContext context) {
    final route = myLocation != null && lineEnd != null
        ? <Polyline>[
            Polyline(
              points: [myLocation!, lineEnd!],
              strokeWidth: 3,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
          ]
        : const <Polyline>[];

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: initialZoom,
        minZoom: 2,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.drag |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.smarttravel.smart_travel_companion',
        ),
        if (route.isNotEmpty) PolylineLayer(polylines: route),
        MarkerLayer(markers: markers),
        if (overlayMarkers.isNotEmpty) MarkerLayer(markers: overlayMarkers),
        if (myLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 36,
                height: 36,
                point: myLocation!,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withValues(alpha: 0.28),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        offset: Offset(0, 2),
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.navigation_rounded,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 6),
            child: Material(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  '© OpenStreetMap',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
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
          child: const Icon(
            Icons.location_pin,
            color: Colors.redAccent,
            size: 40,
          ),
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

  static double zoomFor(bool showAll) => showAll ? 3 : 12.5;
}
