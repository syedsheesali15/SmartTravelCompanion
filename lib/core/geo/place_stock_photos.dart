import 'fake_location.dart';

typedef CuratedSpotPhotos = ({String thumbnailUrl, String fullImageUrl});

/// Stock photos sourced from Wikimedia Commons (HTTPS + permissive CORS for Flutter Web).
///
/// Entries are ordered **identically** to [_pairs] in [fake_location.dart].
const _thumb500 = <String>[
  'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Lake_Tekapo_01.jpg/500px-Lake_Tekapo_01.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Restaurant_at_sunset%2C_Fira%2C_Santorini%2C_Greece_%28approx._GPS_location%29_julesvernex2.jpg/500px-Restaurant_at_sunset%2C_Fira%2C_Santorini%2C_Greece_%28approx._GPS_location%29_julesvernex2.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Moraine_Lake_17092005.jpg/500px-Moraine_Lake_17092005.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/The_Remarkables_from_Queenstown%2C_New_Zealand_08.jpg/500px-The_Remarkables_from_Queenstown%2C_New_Zealand_08.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/View_of_Hallstatt_waterfront_and_churches_from_Hallst%C3%A4tter_See.jpg/500px-View_of_Hallstatt_waterfront_and_churches_from_Hallst%C3%A4tter_See.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Water_reflection_of_Kinkaku-ji_Temple_a_sunny_day%2C_Kyoto%2C_Japan.jpg/500px-Water_reflection_of_Kinkaku-ji_Temple_a_sunny_day%2C_Kyoto%2C_Japan.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Hallgr%C3%ADmskirkja.jpeg/500px-Hallgr%C3%ADmskirkja.jpeg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Tour_Eiffel_Wikimedia_Commons.jpg/500px-Tour_Eiffel_Wikimedia_Commons.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Tegallalang_rice_terraces_SF0001.jpg/500px-Tegallalang_rice_terraces_SF0001.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Fitz_Roy_framed_trees_%28colour_balans%29.jpg/500px-Fitz_Roy_framed_trees_%28colour_balans%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/African_bush_elephant_%28Loxodonta_africana%29%2C_Masai_Mara.jpg/500px-African_bush_elephant_%28Loxodonta_africana%29%2C_Masai_Mara.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Sagrada_Familia%2C_Barcelona_%28P1170687%29.jpg/500px-Sagrada_Familia%2C_Barcelona_%28P1170687%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Lissabon_-_Alfama_-_Largo_Santa_Luzia_-_Streetcar_-_1.jpg/500px-Lissabon_-_Alfama_-_Largo_Santa_Luzia_-_Streetcar_-_1.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Dubai_Skyline_mit_Burj_Khalifa_%2818241030269%29.jpg/500px-Dubai_Skyline_mit_Burj_Khalifa_%2818241030269%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Jemaa_el-Fnaa_at_night.jpg/500px-Jemaa_el-Fnaa_at_night.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Hanoi%2C_Vietnam%2C_Hoan_Kiem_Lake.jpg/500px-Hanoi%2C_Vietnam%2C_Hoan_Kiem_Lake.jpg',
];

String _commons1280Thumb(String commons500Thumb) =>
    commons500Thumb.replaceFirst('/500px-', '/1280px-');

/// Landmark photography aligned with curated titles from [syntheticTravelSpot].
CuratedSpotPhotos curatedSpotPhotos({
  required int albumId,
  required int photoId,
}) {
  final i = syntheticTravelSpotIndex(albumId: albumId, photoId: photoId);
  final thumb = _thumb500[i];
  final full = _commons1280Thumb(thumb);
  return (thumbnailUrl: thumb, fullImageUrl: full);
}
