import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/repositories/place_repository.dart';
import 'connectivity_notifier.dart';

class PlacesNotifier extends ChangeNotifier {
  PlacesNotifier({
    required PlaceRepository repository,
    required ConnectivityNotifier connectivity,
  }) : _repository = repository,
       _connectivity = connectivity {
    connectivity.addListener(_onConnectivityTick);
    unawaited(bootstrap());
  }

  final PlaceRepository _repository;
  final ConnectivityNotifier _connectivity;

  static const int pageSize = 22;

  PlaceQuery _filters = PlaceQuery.initial;
  List<PlaceEntity> _places = const [];
  List<PlaceEntity> _popularPlaces = const [];
  bool _initialBusy = false;
  bool _pageBusy = false;
  bool _silentPaging = false;
  Object? _lastError;

  Timer? _debounce;

  PlaceQuery get filters => _filters;

  List<PlaceEntity> get places => _places;

  /// Home carousel: highest album ids first (stable "popular" rails).
  List<PlaceEntity> get popularPlaces => _popularPlaces;

  bool get initialBusy => _initialBusy;

  bool get pageBusy => _pageBusy || _silentPaging;

  Object? get lastError => _lastError;

  int get refreshCounter => _refreshNonce;
  int _refreshNonce = 0;
  int _remoteNextStart = 0;

  /// Bumped whenever external UI (search field / filter sheet) should resync controllers.
  int get uiRevision => _uiRevision;
  int _uiRevision = 0;

  bool get offline => _connectivity.offline;

  Future<void> _refreshPopularRails() async {
    try {
      _popularPlaces = await _repository.fetchPopularPreview(limit: 12);
    } catch (e, st) {
      debugPrint('popular rails failed $e $st');
    }
  }

  Future<void> _silentPullChunks({
    required int pulls,
    Object? callerTag,
  }) async {
    if (pulls <= 0) return;
    _silentPaging = true;
    notifyListeners();
    try {
      for (var i = 0; i < pulls; i++) {
        await _repository.fetchRemotePage(
          start: _remoteNextStart,
          limit: pageSize,
        );
        _remoteNextStart += pageSize;
      }
    } catch (e, st) {
      debugPrint('$callerTag paging error $e $st');
    } finally {
      _silentPaging = false;
      _places = await _repository.queryLocal(_filters);
      await _refreshPopularRails();
      notifyListeners();
    }
  }

  void _onConnectivityTick() {
    if (!_connectivity.offline && !_initialBusy && _places.isEmpty) {
      unawaited(bootstrap());
      return;
    }
    notifyListeners();
  }

  Future<void> bootstrap() async {
    _initialBusy = true;
    _lastError = null;
    notifyListeners();

    try {
      try {
        await _repository.migrateLegacyWorldFavoritesFromPrefs();
      } catch (e, st) {
        debugPrint('world favorites prefs migration skipped: $e $st');
      }
      _places = await _repository.queryLocal(_filters);
      await _refreshPopularRails();

      // Always attempt network — connectivity_plus often mis-reports desktop / VPN states.
      try {
        await _repository.fetchRemotePage(start: 0, limit: pageSize);
        _remoteNextStart = pageSize;
        _places = await _repository.queryLocal(_filters);
        await _refreshPopularRails();
        await _silentPullChunks(pulls: 11, callerTag: 'warm-start');
      } catch (e, st) {
        debugPrint('bootstrap remote hydrate $e $st');
        _lastError = e;
        _places = await _repository.queryLocal(_filters);
        await _refreshPopularRails();
      }
    } catch (e, st) {
      debugPrint('bootstrap error $e $st');
      _lastError = e;
      _places = await _repository.queryLocal(_filters);
      await _refreshPopularRails();
    } finally {
      _initialBusy = false;
      notifyListeners();
    }
  }

  Future<void> refreshPull() async {
    _refreshNonce++;
    _remoteNextStart = 0;
    await bootstrap();
  }

  Future<void> loadMore() async {
    if (_pageBusy || _silentPaging || _initialBusy) return;
    _pageBusy = true;
    notifyListeners();
    try {
      await _repository.fetchRemotePage(
        start: _remoteNextStart,
        limit: pageSize,
      );
      _remoteNextStart += pageSize;
      _places = await _repository.queryLocal(_filters);
      await _refreshPopularRails();
    } catch (e, st) {
      debugPrint('loadMore error $e $st');
      _lastError = e;
    } finally {
      _pageBusy = false;
      notifyListeners();
    }
  }

  Future<void> _stretchForActiveSearch(String needle) async {
    if (needle.trim().isEmpty) return;

    var guard = 0;
    while (guard < 28 && (await _repository.queryLocal(_filters)).isEmpty) {
      guard++;
      try {
        await _repository.fetchRemotePage(
          start: _remoteNextStart,
          limit: pageSize,
        );
        _remoteNextStart += pageSize;
      } catch (_) {
        break;
      }
    }
    _places = await _repository.queryLocal(_filters);
    await _refreshPopularRails();
    notifyListeners();
  }

  Future<void> applyDraftSearch(String raw) async {
    _debounce?.cancel();
    final draft = raw;
    _debounce = Timer(const Duration(milliseconds: 360), () async {
      final needle = draft.trim();

      _filters = PlaceQuery(
        chip: _filters.chip,
        search: draft,
        sort: _filters.sort,
        region: _filters.region,
        showFavoritesOnly: _filters.showFavoritesOnly,
      );

      _places = await _repository.queryLocal(_filters);

      if (_places.isEmpty && needle.isNotEmpty) {
        await _stretchForActiveSearch(needle);
      }

      await _refreshPopularRails();
      _refreshNonce++;
      notifyListeners();
    });
  }

  Future<void> setChip(HomeChip chip) async {
    _filters = PlaceQuery(
      chip: chip,
      search: _filters.search,
      sort: _filters.sort,
      region: _filters.region,
      showFavoritesOnly: _filters.showFavoritesOnly,
    );
    _places = await _repository.queryLocal(_filters);
    await _refreshPopularRails();
    _refreshNonce++;
    notifyListeners();
  }

  Future<void> applyStructuredFilters({
    required PlaceSort sort,
    required String region,
    required bool favoritesOnlyFromSheet,
    bool replaceSearchFromSheet = false,
    String? searchFromSheet,
  }) async {
    _filters = PlaceQuery(
      chip: favoritesOnlyFromSheet ? HomeChip.favorites : _filters.chip,
      search: replaceSearchFromSheet && searchFromSheet != null
          ? searchFromSheet.trim()
          : _filters.search,
      sort: sort,
      region: region,
      showFavoritesOnly: favoritesOnlyFromSheet,
    );
    _places = await _repository.queryLocal(_filters);
    await _refreshPopularRails();
    _refreshNonce++;
    _uiRevision++;
    notifyListeners();
  }

  Future<void> toggleFavorite(PlaceEntity place) async {
    final next = !place.isFavorite;
    if (place.isWorldPlaceEntry) {
      await _repository.setWorldPlaceFavorite(
        projection: place,
        favorite: next,
      );
    } else {
      await _repository.toggleFavorite(place.id, next);
    }
    if (next) {
      await NotificationService.instance.favoriteAdded(place.title);
    }
    _places = await _repository.queryLocal(_filters);
    await _refreshPopularRails();
    _refreshNonce++;
    notifyListeners();
  }

  /// Re-query the current filters (e.g. after editing a coordinate-based favorite).
  Future<void> refreshPlaces() async {
    _places = await _repository.queryLocal(_filters);
    await _refreshPopularRails();
    _refreshNonce++;
    notifyListeners();
  }

  Future<void> resetFilters() async {
    _filters = PlaceQuery.initial;
    _places = await _repository.queryLocal(_filters);
    await _refreshPopularRails();
    _refreshNonce++;
    _uiRevision++;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _connectivity.removeListener(_onConnectivityTick);
    super.dispose();
  }
}
