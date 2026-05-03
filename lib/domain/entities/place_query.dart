enum HomeChip { all, favorites, recent }

enum PlaceSort { recommended, titleAsc, titleDesc, idAsc }

class PlaceQuery {
  const PlaceQuery({
    required this.chip,
    required this.search,
    required this.sort,
    required this.region,
    required this.showFavoritesOnly,
  });

  final HomeChip chip;
  final String search;
  final PlaceSort sort;
  final String region;
  final bool showFavoritesOnly;

  static const PlaceQuery initial = PlaceQuery(
    chip: HomeChip.all,
    search: '',
    sort: PlaceSort.recommended,
    region: 'All',
    showFavoritesOnly: false,
  );
}
