import 'package:flutter/material.dart';

import '../../../../domain/entities/place_entity.dart';
import '../../../../domain/entities/place_query.dart';
import '../../../provider/places_notifier.dart';
import 'travel_place_tile.dart';

/// [AnimatedList] for Explore — assignment requirement + paging via insertItem.
final class ExplorePlacesAnimatedList extends StatefulWidget {
  const ExplorePlacesAnimatedList({
    super.key,
    required this.notifier,
  });

  final PlacesNotifier notifier;

  @override
  State<ExplorePlacesAnimatedList> createState() =>
      _ExplorePlacesAnimatedListState();
}

final class _ExplorePlacesAnimatedListState
    extends State<ExplorePlacesAnimatedList> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late List<PlaceEntity> _items;
  late String _lastFilterSig;
  late int _lastRefreshCounter;

  static String _sig(PlaceQuery q) =>
      '${q.chip}.${q.search}.${q.region}.${q.sort}.${q.showFavoritesOnly}';

  static bool _sameIdsParallel(List<PlaceEntity> a, List<PlaceEntity> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  static bool _isPrefixIds(List<PlaceEntity> shorter, List<PlaceEntity> longer) {
    if (shorter.length > longer.length) return false;
    for (var i = 0; i < shorter.length; i++) {
      if (shorter[i].id != longer[i].id) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    final n = widget.notifier;
    _items = List.of(n.places);
    _lastFilterSig = _sig(n.filters);
    _lastRefreshCounter = n.refreshCounter;
    n.addListener(_onPlacesChanged);
  }

  @override
  void didUpdateWidget(covariant ExplorePlacesAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_onPlacesChanged);
      widget.notifier.addListener(_onPlacesChanged);
      _listKey = GlobalKey<AnimatedListState>();
      _items = List.of(widget.notifier.places);
      _lastFilterSig = _sig(widget.notifier.filters);
      _lastRefreshCounter = widget.notifier.refreshCounter;
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onPlacesChanged);
    super.dispose();
  }

  void _fullRebuild(List<PlaceEntity> next) {
    setState(() {
      _listKey = GlobalKey<AnimatedListState>();
      _items = List.of(next);
    });
  }

  void _onPlacesChanged() {
    final n = widget.notifier;
    final next = n.places;

    if (n.refreshCounter != _lastRefreshCounter) {
      _lastRefreshCounter = n.refreshCounter;
      _lastFilterSig = _sig(n.filters);
      _fullRebuild(next);
      return;
    }

    final sig = _sig(n.filters);
    if (sig != _lastFilterSig) {
      _lastFilterSig = sig;
      _fullRebuild(next);
      return;
    }

    if (next.length == _items.length && _sameIdsParallel(_items, next)) {
      setState(() => _items = List.of(next));
      return;
    }

    if (next.length > _items.length && _isPrefixIds(_items, next)) {
      final listState = _listKey.currentState;
      for (var i = _items.length; i < next.length; i++) {
        final row = next[i];
        setState(() => _items.add(row));
        listState?.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      }
      return;
    }

    _fullRebuild(next);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      primary: true,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 124),
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        final place = _items[index];
        return TravelPlaceTile(
          place: place,
          animation: animation,
          onFavorite: () => widget.notifier.toggleFavorite(place),
        );
      },
    );
  }
}
