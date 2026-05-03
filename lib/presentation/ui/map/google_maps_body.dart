import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:latlong2/latlong.dart' show LatLng;

import '../../../../core/geo/coords_for_place.dart';
import '../../../../domain/entities/place_entity.dart';

class GoogleMapsBody extends StatefulWidget {
  const GoogleMapsBody({
    super.key,
    required this.showAll,
    required this.places,
    required this.singleLat,
    required this.singleLng,
    required this.markerTitle,
  });

  final bool showAll;
  final List<PlaceEntity> places;
  final double? singleLat;
  final double? singleLng;
  final String markerTitle;

  @override
  State<GoogleMapsBody> createState() => _GoogleMapsBodyState();
}

class _GoogleMapsBodyState extends State<GoogleMapsBody> {
  gm.GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant GoogleMapsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.places.length != widget.places.length || oldWidget.showAll != widget.showAll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMarkers());
    }
  }

  gm.LatLng _gm(LatLng p) => gm.LatLng(p.latitude, p.longitude);

  Future<void> _onMapCreated(gm.GoogleMapController c) async {
    _controller = c;
    await _fitMarkers();
  }

  Future<void> _fitMarkers() async {
    final ctrl = _controller;
    if (!mounted || ctrl == null) return;

    if (!widget.showAll && widget.singleLat != null && widget.singleLng != null) {
      await ctrl.animateCamera(
        gm.CameraUpdate.newCameraPosition(
          gm.CameraPosition(target: gm.LatLng(widget.singleLat!, widget.singleLng!), zoom: 12),
        ),
      );
      return;
    }

    final slice = widget.places.take(80).toList();
    if (slice.isEmpty) {
      await ctrl.animateCamera(gm.CameraUpdate.newLatLngZoom(const gm.LatLng(12, 101), 3));
      return;
    }
    if (slice.length == 1) {
      final p = latLngForPlaceId(slice.first.id);
      await ctrl.animateCamera(gm.CameraUpdate.newLatLngZoom(_gm(p), 11));
      return;
    }

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final place in slice) {
      final p = latLngForPlaceId(place.id);
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    if ((maxLat - minLat) < 1e-6 && (maxLng - minLng) < 1e-6) {
      await ctrl.animateCamera(gm.CameraUpdate.newLatLngZoom(gm.LatLng(minLat, minLng), 9));
      return;
    }

    final bounds = gm.LatLngBounds(
      southwest: gm.LatLng(minLat, minLng),
      northeast: gm.LatLng(maxLat, maxLng),
    );
    try {
      await ctrl.animateCamera(gm.CameraUpdate.newLatLngBounds(bounds, 56));
    } catch (_) {
      await ctrl.animateCamera(
        gm.CameraUpdate.newLatLngZoom(
          gm.LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
          4,
        ),
      );
    }
  }

  gm.CameraPosition _initialCamera() {
    if (!widget.showAll && widget.singleLat != null && widget.singleLng != null) {
      return gm.CameraPosition(target: gm.LatLng(widget.singleLat!, widget.singleLng!), zoom: 12);
    }
    final slice = widget.places.take(math.min(widget.places.length, 80)).toList();
    if (slice.isEmpty) {
      return const gm.CameraPosition(target: gm.LatLng(12, 101), zoom: 3);
    }
    var la = 0.0, ln = 0.0;
    for (final p in slice) {
      final pt = latLngForPlaceId(p.id);
      la += pt.latitude;
      ln += pt.longitude;
    }
    final n = slice.length.toDouble();
    return gm.CameraPosition(target: gm.LatLng(la / n, ln / n), zoom: widget.showAll ? 3 : 5);
  }

  Set<gm.Marker> _markers() {
    if (!widget.showAll && widget.singleLat != null && widget.singleLng != null) {
      return {
        gm.Marker(
          markerId: const gm.MarkerId('target'),
          position: gm.LatLng(widget.singleLat!, widget.singleLng!),
          infoWindow: gm.InfoWindow(title: widget.markerTitle),
        ),
      };
    }

    final out = <gm.Marker>{};
    for (final place in widget.places.take(80)) {
      final llPt = latLngForPlaceId(place.id);
      out.add(
        gm.Marker(
          markerId: gm.MarkerId('${place.id}'),
          position: _gm(llPt),
          infoWindow: gm.InfoWindow(title: place.title),
        ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return gm.GoogleMap(
      initialCameraPosition: _initialCamera(),
      markers: _markers(),
      onMapCreated: _onMapCreated,
      compassEnabled: true,
      zoomControlsEnabled: true,
      mapType: gm.MapType.normal,
    );
  }
}
