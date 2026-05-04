/// English copy for worldwide / geocoded places. Replaces JSONPlaceholder Latin titles in the UI.
String englishBlurbForGeocodedPlace({
  required String placeName,
  required String locationLine,
}) {
  final name = placeName.trim();
  final loc = locationLine.trim();
  final label = name.isEmpty ? 'This place' : name;

  if (loc.isEmpty) {
    return '$label — explore the live weather and map for these coordinates. '
        'The photo is an illustrative travel image chosen for your search.';
  }
  return '$label is in $loc. Use the forecast and map to explore this destination. '
      'The photo is an illustrative travel image chosen for your search.';
}
