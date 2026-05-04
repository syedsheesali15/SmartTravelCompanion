class GeocodePlace {
  const GeocodePlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;

  String get subtitle {
    final parts = <String>[];
    if (admin1 != null && admin1!.trim().isNotEmpty) parts.add(admin1!.trim());
    if (country.trim().isNotEmpty) parts.add(country.trim());
    return parts.join(', ');
  }
}
