import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/database/sqlite_factory.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_place_datasource.dart';
import 'data/datasources/remote_place_datasource.dart';
import 'data/datasources/weather_remote_datasource.dart';
import 'data/repositories/place_repository_impl.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/repositories/place_repository.dart';
import 'domain/repositories/weather_repository.dart';
import 'presentation/provider/connectivity_notifier.dart';
import 'presentation/provider/places_notifier.dart';
import 'presentation/provider/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureSqliteFactory();
  await NotificationService.instance.initialize();

  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadPrefs();

  final router = buildRouter();

  runApp(
    SmartTravelApp(
      themeNotifier: themeNotifier,
      router: router,
    ),
  );
}

class SmartTravelApp extends StatefulWidget {
  const SmartTravelApp({
    super.key,
    required this.themeNotifier,
    required this.router,
  });

  final ThemeNotifier themeNotifier;
  final GoRouter router;

  @override
  State<SmartTravelApp> createState() => _SmartTravelAppState();
}

class _SmartTravelAppState extends State<SmartTravelApp> {
  late final PlaceRepository _placeRepo = PlaceRepositoryImpl(
    remote: RemotePlaceDataSource(),
    local: LocalPlaceDataSource(),
  );
  late final WeatherRepository _weatherRepo = WeatherRepositoryImpl(
    remote: WeatherRemoteDataSource(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PlaceRepository>.value(value: _placeRepo),
        Provider<WeatherRepository>.value(value: _weatherRepo),
        ChangeNotifierProvider.value(value: widget.themeNotifier),
        ChangeNotifierProvider(create: (_) => ConnectivityNotifier()),
        ChangeNotifierProvider(
          create: (ctx) => PlacesNotifier(
            repository: ctx.read<PlaceRepository>(),
            connectivity: ctx.read<ConnectivityNotifier>(),
          ),
        ),
      ],
      child: ListenableBuilder(
        listenable: widget.themeNotifier,
        builder: (context, _) {
          final light = lightScheme();
          final dark = darkScheme();
          return MaterialApp.router(
            title: 'Smart Travel Companion',
            debugShowCheckedModeBanner: false,
            themeMode: widget.themeNotifier.mode,
            theme: lightTheme(light),
            darkTheme: darkTheme(dark),
            routerConfig: widget.router,
          );
        },
      ),
    );
  }
}
