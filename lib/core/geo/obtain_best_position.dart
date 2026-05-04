import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart' show TargetPlatform;
import 'package:geolocator/geolocator.dart';

/// Returns false for (0,0) and out-of-range coordinates.
bool isValidGpsSample(Position p) {
  if (p.latitude.isNaN || p.longitude.isNaN) return false;
  if (p.latitude < -90 || p.latitude > 90) return false;
  if (p.longitude < -180 || p.longitude > 180) return false;
  if (p.latitude.abs() < 1e-6 && p.longitude.abs() < 1e-6) return false;
  return true;
}

bool _fixLooksStale(Position p) {
  final age = DateTime.now().difference(p.timestamp);
  return age > const Duration(minutes: 3);
}

LocationSettings _settingsFor(
  LocationAccuracy accuracy,
  Duration timeout,
) {
  if (kIsWeb) {
    return LocationSettings(accuracy: accuracy, distanceFilter: 0);
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidSettings(
      accuracy: accuracy,
      distanceFilter: 0,
      timeLimit: timeout,
      foregroundNotificationConfig: null,
    );
  }
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return AppleSettings(
      accuracy: accuracy,
      activityType: ActivityType.otherNavigation,
      distanceFilter: 0,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: false,
      timeLimit: timeout,
    );
  }
  return LocationSettings(accuracy: accuracy, distanceFilter: 0);
}

/// Call only after [LocationPermission] is granted and services are enabled.
/// Uses a fresh [getCurrentPosition] (not last-known) with platform settings
/// so distance-to-pin reflects the real GPS fix when the device allows it.
Future<Position?> obtainBestGpsPosition() async {
  if (kIsWeb) return null;

  Future<Position?> once(LocationAccuracy accuracy, Duration timeout) async {
    try {
      final settings = _settingsFor(accuracy, timeout);
      final p = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(timeout + const Duration(seconds: 2));
      if (!isValidGpsSample(p)) return null;
      return p;
    } catch (_) {
      return null;
    }
  }

  Future<Position?> onceRetryIfStale(
    LocationAccuracy accuracy,
    Duration timeout,
  ) async {
    final first = await once(accuracy, timeout);
    if (first == null) return null;
    if (_fixLooksStale(first)) {
      final second = await once(accuracy, timeout);
      return second ?? first;
    }
    return first;
  }

  final nav = await onceRetryIfStale(
    LocationAccuracy.bestForNavigation,
    const Duration(seconds: 42),
  );
  if (nav != null) return nav;

  final high = await onceRetryIfStale(
    LocationAccuracy.high,
    const Duration(seconds: 28),
  );
  if (high != null) return high;

  final med = await once(
    LocationAccuracy.medium,
    const Duration(seconds: 20),
  );
  return med;
}
