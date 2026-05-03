import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/repositories/place_repository.dart';
import '../datasources/local_place_datasource.dart';
import '../datasources/remote_place_datasource.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  PlaceRepositoryImpl({
    required RemotePlaceDataSource remote,
    required LocalPlaceDataSource local,
  }) : _remote = remote,
       _local = local;

  final RemotePlaceDataSource _remote;
  final LocalPlaceDataSource _local;

  @override
  Future<List<PlaceEntity>> queryLocal(PlaceQuery query) => _local.fetchMatching(query);

  @override
  Future<List<PlaceEntity>> fetchPopularPreview({int limit = 12}) => _local.fetchPopular(limit: limit);

  @override
  Future<void> fetchRemotePage({
    required int start,
    required int limit,
  }) async {
    final photos = await _remote.fetchPhotos(start: start, limit: limit);
    await _local.upsertPhotos(photos);
  }

  @override
  Future<PlaceEntity?> getById(int id) => _local.getById(id);

  @override
  Future<void> toggleFavorite(int id, bool value) => _local.updateFavorite(id: id, value: value);

  @override
  Future<void> markRecent(int id) =>
      _local.bumpViewed(id, DateTime.now().millisecondsSinceEpoch);
}
