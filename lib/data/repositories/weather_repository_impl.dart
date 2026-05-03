import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({WeatherRemoteDataSource? remote}) : _remote = remote ?? WeatherRemoteDataSource();

  final WeatherRemoteDataSource _remote;

  @override
  Future<WeatherEntity> fetchCurrent({
    required double latitude,
    required double longitude,
  }) =>
      _remote.fetchCurrent(latitude: latitude, longitude: longitude);
}
