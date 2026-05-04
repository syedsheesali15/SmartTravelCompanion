import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/place_query.dart';
import '../../provider/places_notifier.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController _search;
  PlaceSort _sort = PlaceSort.recommended;
  String _region = 'All';
  bool _favoritesOnly = false;

  final _regions = ['All', 'Pacific', 'Europe', 'Americas', 'Asia', 'Africa'];

  @override
  void initState() {
    super.initState();
    final n = context.read<PlacesNotifier>().filters;
    _search = TextEditingController(text: n.search);
    _sort = n.sort;
    _region = n.region;
    _favoritesOnly = n.showFavoritesOnly;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 18,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Search & filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search places...',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlaceSort>(
              value: _sort,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: const [
                DropdownMenuItem(
                  value: PlaceSort.recommended,
                  child: Text('Recommended'),
                ),
                DropdownMenuItem(
                  value: PlaceSort.titleAsc,
                  child: Text('Title A → Z'),
                ),
                DropdownMenuItem(
                  value: PlaceSort.titleDesc,
                  child: Text('Title Z → A'),
                ),
                DropdownMenuItem(
                  value: PlaceSort.idAsc,
                  child: Text('Place id ascending'),
                ),
              ],
              onChanged: (v) =>
                  setState(() => _sort = v ?? PlaceSort.recommended),
            ),
            const SizedBox(height: 12),
            Text('Show', style: Theme.of(context).textTheme.labelLarge),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: !_favoritesOnly,
                  onSelected: (_) => setState(() => _favoritesOnly = false),
                ),
                FilterChip(
                  label: const Text('Favorites'),
                  selected: _favoritesOnly,
                  onSelected: (_) => setState(() => _favoritesOnly = true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _region,
              decoration: const InputDecoration(labelText: 'Region'),
              items: _regions
                  .map(
                    (region) =>
                        DropdownMenuItem(value: region, child: Text(region)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _region = value ?? 'All'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _search.clear();
                      _sort = PlaceSort.recommended;
                      _region = 'All';
                      _favoritesOnly = false;
                    });
                  },
                  child: const Text('Clear all'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    final notifier = context.read<PlacesNotifier>();
                    await notifier.applyStructuredFilters(
                      sort: _sort,
                      region: _region,
                      favoritesOnlyFromSheet: _favoritesOnly,
                      replaceSearchFromSheet: true,
                      searchFromSheet: _search.text,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Apply filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
