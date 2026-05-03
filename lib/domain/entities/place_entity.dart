class PlaceEntity {
  const PlaceEntity({
    required this.id,
    required this.albumId,
    required this.title,
    required this.fullImageUrl,
    required this.thumbnailUrl,
    required this.locationLine,
    required this.aboutText,
    required this.regionBucket,
    required this.isFavorite,
    required this.lastViewedMs,
  });

  final int id;
  final int albumId;
  final String title;
  final String fullImageUrl;
  final String thumbnailUrl;
  /// "City / landmark, Country" line from mocked catalog.
  final String locationLine;
  final String aboutText;
  final String regionBucket;
  final bool isFavorite;
  final int? lastViewedMs;

  PlaceEntity copyWith({
    int? id,
    int? albumId,
    String? title,
    String? fullImageUrl,
    String? thumbnailUrl,
    String? locationLine,
    String? aboutText,
    String? regionBucket,
    bool? isFavorite,
    int? lastViewedMs,
  }) => PlaceEntity(
        id: id ?? this.id,
        albumId: albumId ?? this.albumId,
        title: title ?? this.title,
        fullImageUrl: fullImageUrl ?? this.fullImageUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        locationLine: locationLine ?? this.locationLine,
        aboutText: aboutText ?? this.aboutText,
        regionBucket: regionBucket ?? this.regionBucket,
        isFavorite: isFavorite ?? this.isFavorite,
        lastViewedMs: lastViewedMs ?? this.lastViewedMs,
      );
}
