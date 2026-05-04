import 'fake_location.dart';
import 'predefined_destinations.dart';

typedef CuratedSpotPhotos = ({String thumbnailUrl, String fullImageUrl});

String _commons1280Thumb(String commons500Thumb) =>
    commons500Thumb.replaceFirst('/500px-', '/1280px-');

/// Landmark photography aligned with curated titles from [syntheticTravelSpot].
CuratedSpotPhotos curatedSpotPhotos({
  required int albumId,
  required int photoId,
}) {
  final i = syntheticTravelSpotIndex(albumId: albumId, photoId: photoId);
  final thumb = PredefinedDestinations.commonsThumb500(i);
  final full = _commons1280Thumb(thumb);
  return (thumbnailUrl: thumb, fullImageUrl: full);
}
