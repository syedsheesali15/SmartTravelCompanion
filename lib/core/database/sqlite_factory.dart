import 'sqlite_factory_stub.dart'
    if (dart.library.html) 'sqlite_factory_web.dart'
    as platform;

void configureSqliteFactory() => platform.configureSqliteFactory();
