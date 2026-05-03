final class SyntheticLocationResult {
  const SyntheticLocationResult(this.titleLine, this.regionBucket);

  /// e.g. "Lake Tekapo, New Zealand"
  final String titleLine;
  /// Filter bucket (Pacific / Europe …)
  final String regionBucket;
}

SyntheticLocationResult syntheticTravelSpot({
  required int albumId,
  required int photoId,
}) {
  const pairs = [
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
  final i = ((albumId.abs() % pairs.length) + (photoId.abs() % pairs.length)) % pairs.length;
  final p = pairs[i];
  final line = '${p.$1}, ${p.$2}';
  return SyntheticLocationResult(line, p.$3);
}
