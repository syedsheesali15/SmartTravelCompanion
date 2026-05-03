class WeatherEntity {
  const WeatherEntity({
    required this.temperatureC,
    required this.apparentC,
    required this.humidityPct,
    required this.windKmh,
    required this.conditionLabel,
  });

  final double temperatureC;
  final double apparentC;
  final int humidityPct;
  final double windKmh;
  final String conditionLabel;
}
