import 'predefined_destinations.dart';

final class SyntheticLocationResult {
  const SyntheticLocationResult(this.titleLine, this.regionBucket);

  /// e.g. "Lake Tekapo, New Zealand"
  final String titleLine;

  /// Filter bucket (Pacific / Europe …)
  final String regionBucket;
}

/// Matches [syntheticTravelSpot] bucketing — used to align stock imagery with headings.
int syntheticTravelSpotIndex({required int albumId, required int photoId}) {
  final n = PredefinedDestinations.length;
  return ((albumId.abs() % n) + (photoId.abs() % n)) % n;
}

SyntheticLocationResult syntheticTravelSpot({
  required int albumId,
  required int photoId,
}) {
  final i = syntheticTravelSpotIndex(albumId: albumId, photoId: photoId);
  return SyntheticLocationResult(
    PredefinedDestinations.titleLine(i),
    PredefinedDestinations.regionBucket(i),
  );
}
