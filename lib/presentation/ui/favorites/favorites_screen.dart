import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/place_query.dart';
import '../../provider/places_notifier.dart';
import '../home/widgets/travel_place_tile.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesNotifier>().setChip(HomeChip.favorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PlacesNotifier>();
    final favorites = notifier.places.toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('My favorites')),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  'Tap the heart icons on Explore to collect favorites—even offline!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : AnimatedList(
              key: ValueKey(
                'fav-${favorites.length}-${notifier.refreshCounter}',
              ),
              initialItemCount: favorites.length,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
              itemBuilder: (context, index, animation) => TravelPlaceTile(
                place: favorites[index],
                animation: animation,
                onFavorite: () => notifier.toggleFavorite(favorites[index]),
              ),
            ),
    );
  }
}
