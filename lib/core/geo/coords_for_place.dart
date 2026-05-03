import 'package:latlong2/latlong.dart';

/// Deterministic lat/lng so Open-Meteo returns stable weather without a geocoder.
LatLng latLngForPlaceId(int placeId) {
  final normalized = ((placeId % 1000) / 1000.0); // [0,1)
  final lat = ((normalized * 160) / 160.0) * 140 - 70; // roughly [-70..70]
  final lngFraction = (((placeId * 9973) % 1000) / 1000.0);
  final lng = lngFraction * 360 - 180; // roughly full longitude range
  return LatLng(lat.clamp(-60.0, 60.0), lng.clamp(-180.0, 179.999));
}
