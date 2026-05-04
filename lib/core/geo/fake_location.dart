final class SyntheticLocationResult {
  const SyntheticLocationResult(this.titleLine, this.regionBucket);

  /// e.g. "Lake Tekapo, New Zealand"
  final String titleLine;

  /// Filter bucket (Pacific / Europe …)
  final String regionBucket;
}

const _pairs = <
    (
      String name,
      String country,
      String regionBucket,
    )>[
  ('Lake Tekapo', 'New Zealand', 'Pacific'),
  ('Santorini', 'Greece', 'Europe'),
  ('Banff Town', 'Canada', 'Americas'),
  ('Queenstown', 'New Zealand', 'Pacific'),
  ('Hallstatt', 'Austria', 'Europe'),
  ('Kyoto', 'Japan', 'Asia'),
  ('Reykjavik', 'Iceland', 'Europe'),
  ('Paris', 'France', 'Europe'),
  ('Bali Highlands', 'Indonesia', 'Asia'),
  ('Patagonia', 'Argentina', 'Americas'),
  ('Masai Mara', 'Kenya', 'Africa'),
  ('Barcelona', 'Spain', 'Europe'),
  ('Lisbon', 'Portugal', 'Europe'),
  ('Dubai Skylines', 'United Arab Emirates', 'Asia'),
  ('Marrakech Medina', 'Morocco', 'Africa'),
  ('Hanoi Old Quarter', 'Vietnam', 'Asia'),
];

/// Matches [syntheticTravelSpot] bucketing — used to align stock imagery with headings.
int syntheticTravelSpotIndex({required int albumId, required int photoId}) {
  final n = _pairs.length;
  return ((albumId.abs() % n) + (photoId.abs() % n)) % n;
}

SyntheticLocationResult syntheticTravelSpot({
  required int albumId,
  required int photoId,
}) {
  final p = _pairs[syntheticTravelSpotIndex(albumId: albumId, photoId: photoId)];
  return SyntheticLocationResult('${p.$1}, ${p.$2}', p.$3);
}
