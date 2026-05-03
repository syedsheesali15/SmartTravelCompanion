import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../domain/entities/place_query.dart';
import '../../provider/connectivity_notifier.dart';
import '../../provider/places_notifier.dart';
import '../drawer/app_drawer.dart';
import '../filters/filter_sheet.dart';
import 'widgets/travel_place_tile.dart';

/// Explore Places home — matches assignment kit (search row + pills + stacked cards).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchCtrl;
  int _lastUiRevision = -1;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final metrics = notification.metrics;
    if (metrics.pixels > metrics.maxScrollExtent - 320) {
      context.read<PlacesNotifier>().loadMore();
    }
    return false;
  }

  Future<void> _openFilters(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  InputDecoration _searchDecoration(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final hintClr = light ? const Color(0xFF94A3B8) : null;
    final prefixClr = light ? const Color(0xFF64748B) : AppColors.primary.withValues(alpha: .75);

    if (light) {
      return InputDecoration(
        hintText: 'Search places...',
        hintStyle: TextStyle(color: hintClr, fontWeight: FontWeight.w400),
        prefixIcon: Icon(Icons.search_rounded, color: prefixClr),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      );
    }

    return InputDecoration(
      hintText: 'Search places...',
      hintStyle: TextStyle(color: hintClr),
      prefixIcon: Icon(Icons.search_rounded, color: prefixClr),
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.35),
      ),
    );
  }

  Widget _filterSquare(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final border = light ? const Color(0xFFE2E8F0) : Colors.white24;
    final bg = light ? Colors.white : AppColors.darkSurface;
    final iconClr = light ? const Color(0xFF64748B) : Colors.white70;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border)),
      elevation: light ? 0 : 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openFilters(context),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.filter_alt_outlined, color: iconClr, size: 22),
        ),
      ),
    );
  }

  Widget _pillChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final light = Theme.of(context).brightness == Brightness.light;

    final Color bg;
    final Color fg;
    if (light) {
      if (selected) {
        bg = AppColors.primary;
        fg = Colors.white;
      } else {
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
      }
    } else {
      if (selected) {
        bg = AppColors.primary;
        fg = Colors.white;
      } else {
        bg = AppColors.darkSurface;
        fg = Colors.white70;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24),
              border: selected
                  ? null
                  : Border.all(color: light ? const Color(0xFFE2E8F0) : Colors.white24),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityNotifier>();
    final notifier = context.watch<PlacesNotifier>();
    final offline = connectivity.offline || notifier.offline;
    final light = Theme.of(context).brightness == Brightness.light;

    if (_lastUiRevision != notifier.uiRevision) {
      _lastUiRevision = notifier.uiRevision;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final t = notifier.filters.search;
        if (_searchCtrl.text != t) {
          _searchCtrl.value = TextEditingValue(
            text: t,
            selection: TextSelection.collapsed(offset: t.length.clamp(0, t.length)),
          );
        }
      });
    }

    final appBarFg = light ? const Color(0xFF0F172A) : Theme.of(context).colorScheme.onSurface;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: light
          ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: light ? Colors.white : AppColors.darkBackground,
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: light ? Colors.white : Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          foregroundColor: appBarFg,
          iconTheme: IconThemeData(color: appBarFg),
          actionsIconTheme: IconThemeData(color: appBarFg),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Text(
            'Explore Places',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: appBarFg,
                ),
          ),
          actions: [
            IconButton(
              tooltip: 'Travel tip notification',
              onPressed: NotificationService.instance.travelTipMorning,
              icon: const Icon(Icons.notifications_outlined),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 280),
              opacity: offline ? 1 : 0,
              child: offline
                  ? Material(
                      color: AppColors.primary.withValues(alpha: .08),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "You're offline — SQLite cache only.",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => context.read<PlacesNotifier>().bootstrap(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (!notifier.initialBusy &&
                notifier.places.isEmpty &&
                notifier.lastError != null)
              Material(
                color: AppColors.accentHeart.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cloud_off_rounded, color: AppColors.accentHeart),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Could not refresh places from the network: ${notifier.lastError}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => notifier.refreshPull(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: light ? const Color(0xFF0F172A) : null,
                          ),
                      decoration: _searchDecoration(context),
                      onChanged: notifier.applyDraftSearch,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _filterSquare(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _pillChip(
                      context: context,
                      label: 'All',
                      selected: notifier.filters.chip == HomeChip.all,
                      onTap: () => notifier.setChip(HomeChip.all),
                    ),
                    _pillChip(
                      context: context,
                      label: 'Favorites',
                      selected: notifier.filters.chip == HomeChip.favorites,
                      onTap: () => notifier.setChip(HomeChip.favorites),
                    ),
                    _pillChip(
                      context: context,
                      label: 'Recent',
                      selected: notifier.filters.chip == HomeChip.recent,
                      onTap: () => notifier.setChip(HomeChip.recent),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildExplorer(context, notifier, offline)),
          ],
        ),
      ),
    );
  }

  Widget _buildExplorer(BuildContext context, PlacesNotifier notifier, bool offlineBannerVisible) {
    if (notifier.initialBusy) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (notifier.places.isEmpty) {
      final hasTypedSearch = notifier.filters.search.trim().isNotEmpty;
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: notifier.refreshPull,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (hasTypedSearch) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Nothing matched that search yet — relax filters or try another spelling.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 72),
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.manage_search_rounded,
                  size: 72,
                  color: AppColors.primary.withValues(alpha: .94),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No places found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 34),
              child: Text(
                'Relax filters or try another spelling. Kyoto, Santorini, Paris, Morocco, Bali—and “Lake Tekapo”—'
                'unlock once the catalog finishes syncing.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: notifier.resetFilters,
                child: const Text('Clear filters'),
              ),
            ),
            if (!offlineBannerVisible && notifier.filters.search.trim().length >= 2)
              Padding(
                padding: const EdgeInsets.only(top: 96),
                child: Center(
                  child: TextButton.icon(
                    onPressed: notifier.refreshPull,
                    icon: const Icon(Icons.cloud_download_rounded),
                    label: const Text('Rebuild catalog cache'),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final listSalt =
        '${notifier.refreshCounter}-${notifier.filters.chip}-${notifier.filters.search}-${notifier.filters.region}-${notifier.filters.sort}-${notifier.filters.showFavoritesOnly}-${notifier.places.length}';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: notifier.refreshPull,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView.builder(
              key: ValueKey(listSalt),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 124),
              itemCount: notifier.places.length,
              itemBuilder: (context, index) {
                final place = notifier.places[index];
                return TravelPlaceTile(
                  place: place,
                  animation: const AlwaysStoppedAnimation<double>(1),
                  onFavorite: () => notifier.toggleFavorite(place),
                );
              },
            ),
            if (notifier.pageBusy)
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: notifier.pageBusy ? 1 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: .94),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: Theme.of(context).brightness == Brightness.dark ? .42 : .08,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
