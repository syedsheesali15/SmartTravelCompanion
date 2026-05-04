import 'package:latlong2/latlong.dart';

/// Curated landmark list: imagery + **real latitude/longitude** for Open‑Meteo
/// weather (`api.open-meteo.com`) instead of flaky name search / synthetic hashes.
abstract final class PredefinedDestinations {
  PredefinedDestinations._();

  static const List<
      ({
        String spot,
        String countryLine,
        String region,
        String commonsThumb500,
        double lat,
        double lng,
      })> entries =
      [
    (
      spot: 'Lake Tekapo',
      countryLine: 'New Zealand',
      region: 'Pacific',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Lake_Tekapo_01.jpg/500px-Lake_Tekapo_01.jpg',
      lat: -43.8833,
      lng: 170.5167,
    ),
    (
      spot: 'Santorini',
      countryLine: 'Greece',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Restaurant_at_sunset%2C_Fira%2C_Santorini%2C_Greece_%28approx._GPS_location%29_julesvernex2.jpg/500px-Restaurant_at_sunset%2C_Fira%2C_Santorini%2C_Greece_%28approx._GPS_location%29_julesvernex2.jpg',
      lat: 36.3932,
      lng: 25.4616,
    ),
    (
      spot: 'Banff Town',
      countryLine: 'Canada',
      region: 'Americas',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Moraine_Lake_17092005.jpg/500px-Moraine_Lake_17092005.jpg',
      lat: 51.1784,
      lng: -115.5708,
    ),
    (
      spot: 'Queenstown',
      countryLine: 'New Zealand',
      region: 'Pacific',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/The_Remarkables_from_Queenstown%2C_New_Zealand_08.jpg/500px-The_Remarkables_from_Queenstown%2C_New_Zealand_08.jpg',
      lat: -45.0312,
      lng: 168.6627,
    ),
    (
      spot: 'Hallstatt',
      countryLine: 'Austria',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/View_of_Hallstatt_waterfront_and_churches_from_Hallst%C3%A4tter_See.jpg/500px-View_of_Hallstatt_waterfront_and_churches_from_Hallst%C3%A4tter_See.jpg',
      lat: 47.5619,
      lng: 13.6499,
    ),
    (
      spot: 'Kyoto',
      countryLine: 'Japan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Water_reflection_of_Kinkaku-ji_Temple_a_sunny_day%2C_Kyoto%2C_Japan.jpg/500px-Water_reflection_of_Kinkaku-ji_Temple_a_sunny_day%2C_Kyoto%2C_Japan.jpg',
      lat: 35.0394,
      lng: 135.7298,
    ),
    (
      spot: 'Reykjavik',
      countryLine: 'Iceland',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Hallgr%C3%ADmskirkja.jpeg/500px-Hallgr%C3%ADmskirkja.jpeg',
      lat: 64.1467,
      lng: -21.9426,
    ),
    (
      spot: 'Paris',
      countryLine: 'France',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Tour_Eiffel_Wikimedia_Commons.jpg/500px-Tour_Eiffel_Wikimedia_Commons.jpg',
      lat: 48.8584,
      lng: 2.2945,
    ),
    (
      spot: 'Bali Highlands',
      countryLine: 'Indonesia',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Tegallalang_rice_terraces_SF0001.jpg/500px-Tegallalang_rice_terraces_SF0001.jpg',
      lat: -8.4353,
      lng: 115.2793,
    ),
    (
      spot: 'Patagonia',
      countryLine: 'Argentina',
      region: 'Americas',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Fitz_Roy_framed_trees_%28colour_balans%29.jpg/500px-Fitz_Roy_framed_trees_%28colour_balans%29.jpg',
      lat: -49.2794,
      lng: -72.8874,
    ),
    (
      spot: 'Masai Mara',
      countryLine: 'Kenya',
      region: 'Africa',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/African_bush_elephant_%28Loxodonta_africana%29%2C_Masai_Mara.jpg/500px-African_bush_elephant_%28Loxodonta_africana%29%2C_Masai_Mara.jpg',
      lat: -1.4932,
      lng: 35.1439,
    ),
    (
      spot: 'Barcelona',
      countryLine: 'Spain',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Sagrada_Familia%2C_Barcelona_%28P1170687%29.jpg/500px-Sagrada_Familia%2C_Barcelona_%28P1170687%29.jpg',
      lat: 41.4036,
      lng: 2.1744,
    ),
    (
      spot: 'Lisbon',
      countryLine: 'Portugal',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Lissabon_-_Alfama_-_Largo_Santa_Luzia_-_Streetcar_-_1.jpg/500px-Lissabon_-_Alfama_-_Largo_Santa_Luzia_-_Streetcar_-_1.jpg',
      lat: 38.7119,
      lng: -9.1309,
    ),
    (
      spot: 'Dubai Skylines',
      countryLine: 'United Arab Emirates',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Dubai_Skyline_mit_Burj_Khalifa_%2818241030269%29.jpg/500px-Dubai_Skyline_mit_Burj_Khalifa_%2818241030269%29.jpg',
      lat: 25.1972,
      lng: 55.2744,
    ),
    (
      spot: 'Marrakech Medina',
      countryLine: 'Morocco',
      region: 'Africa',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Jemaa_el-Fnaa_at_night.jpg/500px-Jemaa_el-Fnaa_at_night.jpg',
      lat: 31.6259,
      lng: -7.9891,
    ),
    (
      spot: 'Hanoi Old Quarter',
      countryLine: 'Vietnam',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Hanoi%2C_Vietnam%2C_Hoan_Kiem_Lake.jpg/500px-Hanoi%2C_Vietnam%2C_Hoan_Kiem_Lake.jpg',
      lat: 21.0278,
      lng: 105.8342,
    ),

    (
      spot: 'Colosseum',
      countryLine: 'Italy',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Colosseum_in_Rome%2C_Italy_-_April_2007.jpg/500px-Colosseum_in_Rome%2C_Italy_-_April_2007.jpg',
      lat: 41.8902,
      lng: 12.4922,
    ),
    (
      spot: 'Tower Bridge',
      countryLine: 'United Kingdom',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Tower_Bridge_from_Shad_Thames.jpg/500px-Tower_Bridge_from_Shad_Thames.jpg',
      lat: 51.5055,
      lng: -0.0754,
    ),
    (
      spot: 'Brooklyn Bridge',
      countryLine: 'United States',
      region: 'Americas',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Brooklyn_Bridge_at_Night.jpg/500px-Brooklyn_Bridge_at_Night.jpg',
      lat: 40.7061,
      lng: -73.9969,
    ),
    (
      spot: 'Taj Mahal',
      countryLine: 'India',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Taj_Mahal_in_March_2004.jpg/500px-Taj_Mahal_in_March_2004.jpg',
      lat: 27.1751,
      lng: 78.0421,
    ),
    (
      spot: 'Petra Treasury',
      countryLine: 'Jordan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Al_Khazneh_Petra.jpg/500px-Al_Khazneh_Petra.jpg',
      lat: 30.3225,
      lng: 35.4519,
    ),
    (
      spot: 'Sydney Opera House',
      countryLine: 'Australia',
      region: 'Pacific',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Sydney_Opera_House_Sails.jpg/500px-Sydney_Opera_House_Sails.jpg',
      lat: -33.8568,
      lng: 151.2153,
    ),
    (
      spot: 'Matterhorn',
      countryLine: 'Switzerland',
      region: 'Europe',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Matterhorn_from_Domh%C3%BCtte_-_2.jpg/500px-Matterhorn_from_Domh%C3%BCtte_-_2.jpg',
      lat: 45.9763,
      lng: 7.6586,
    ),
    (
      spot: 'Angkor Wat',
      countryLine: 'Cambodia',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Angkor_Wat.jpg/500px-Angkor_Wat.jpg',
      lat: 13.4125,
      lng: 103.867,
    ),
    (
      spot: 'Christ the Redeemer',
      countryLine: 'Brazil',
      region: 'Americas',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Christ_the_Redeemer_-_Cristo_Redentor.jpg/500px-Christ_the_Redeemer_-_Cristo_Redentor.jpg',
      lat: -22.9519,
      lng: -43.2105,
    ),
    (
      spot: 'Machu Picchu',
      countryLine: 'Peru',
      region: 'Americas',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Machu_Picchu%2C_Peru.jpg/500px-Machu_Picchu%2C_Peru.jpg',
      lat: -13.1633,
      lng: -72.5449,
    ),

    (
      spot: 'Mazar-e-Quaid (Quaid Tomb)',
      countryLine: 'Karachi, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Mazar_e_Quaid_-_Karachi.jpg/500px-Mazar_e_Quaid_-_Karachi.jpg',
      lat: 24.8758,
      lng: 67.0389,
    ),
    (
      spot: 'Kund Malir Beach',
      countryLine: 'Balochistan, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Kund_Malir_beach.jpg/500px-Kund_Malir_beach.jpg',
      lat: 25.2326,
      lng: 66.7085,
    ),
    (
      spot: 'Murree (Mall Road)',
      countryLine: 'Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Mall_Road%2C_Murree.jpg/500px-Mall_Road%2C_Murree.jpg',
      lat: 33.904,
      lng: 73.3898,
    ),
    (
      spot: 'Murree skyline',
      countryLine: 'Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Murree_city.jpg/500px-Murree_city.jpg',
      lat: 33.907,
      lng: 73.3903,
    ),
    (
      spot: 'Badshahi Mosque',
      countryLine: 'Lahore, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Badshahi_Mosque%2C_Lahore%2C_Pakistan.jpg/500px-Badshahi_Mosque%2C_Lahore%2C_Pakistan.jpg',
      lat: 31.5879,
      lng: 74.3095,
    ),
    (
      spot: 'Faisal Mosque',
      countryLine: 'Islamabad, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Faisal_Mosque%2C_Islamabad.jpg/500px-Faisal_Mosque%2C_Islamabad.jpg',
      lat: 33.729,
      lng: 73.0745,
    ),
    (
      spot: 'Karimabad (Hunza Valley)',
      countryLine: 'Gilgit-Baltistan, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Karimabad%2C_Hunza.jpg/500px-Karimabad%2C_Hunza.jpg',
      lat: 36.327,
      lng: 74.6593,
    ),
    (
      spot: 'Lahore Fort & Old City',
      countryLine: 'Lahore, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Lahore_Fort_view_from_a_restaurant_rooftop_in_Fort_Food_Street_managed_by_Walled_City_of_Lahore_Authority_%28WCLA%29.jpg/500px-Lahore_Fort_view_from_a_restaurant_rooftop_in_Fort_Food_Street_managed_by_Walled_City_of_Lahore_Authority_%28WCLA%29.jpg',
      lat: 31.588,
      lng: 74.3109,
    ),
    (
      spot: 'Mohenjo-daro',
      countryLine: 'Sindh, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Mohenjo-daro.jpg/500px-Mohenjo-daro.jpg',
      lat: 27.3311,
      lng: 68.1489,
    ),
    (
      spot: 'Deosai National Park',
      countryLine: 'Gilgit-Baltistan, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Deosai_Plateau.jpg/500px-Deosai_Plateau.jpg',
      lat: 35.0695,
      lng: 75.5795,
    ),
    (
      spot: 'Satpara Lake',
      countryLine: 'Skardu, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Satpara_Lake_Skardu.jpg/500px-Satpara_Lake_Skardu.jpg',
      lat: 35.2245,
      lng: 75.6276,
    ),
    (
      spot: 'Margalla Hills',
      countryLine: 'Islamabad, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Margalla_Hills_Islamabad.jpg/500px-Margalla_Hills_Islamabad.jpg',
      lat: 33.7376,
      lng: 73.0476,
    ),
    (
      spot: 'Mubarak Village Beach',
      countryLine: 'Karachi (Mubarak Goth), Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Mubarak_Village.jpg/500px-Mubarak_Village.jpg',
      lat: 24.8495,
      lng: 66.7345,
    ),
    (
      spot: 'Charna Island',
      countryLine: 'Arabian Sea (near Karachi), Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Charna_Island.jpg/500px-Charna_Island.jpg',
      lat: 24.915,
      lng: 66.605,
    ),
    (
      spot: 'Gorakh Hill Station',
      countryLine: 'Dadu District, Sindh, Pakistan',
      region: 'Asia',
      commonsThumb500:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Gorakh_Hill_Station.jpg/500px-Gorakh_Hill_Station.jpg',
      lat: 26.865,
      lng: 67.095,
    ),
  ];

  static int get length => entries.length;

  static String titleLine(int index) {
    final e = entries[index % entries.length];
    return '${e.spot}, ${e.countryLine}';
  }

  static String regionBucket(int index) => entries[index % entries.length].region;

  static String commonsThumb500(int index) =>
      entries[index % entries.length].commonsThumb500;

  /// Matches [PlaceEntity.locationLine] (`spot, country/subregion`).
  static LatLng? tryLatLngForLocationLine(String raw) {
    final want = _norm(raw);
    if (want.isEmpty) return null;
    for (final e in entries) {
      final line = '${e.spot}, ${e.countryLine}';
      if (_norm(line) == want) {
        return LatLng(e.lat, e.lng);
      }
    }
    return null;
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
