import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityNotifier extends ChangeNotifier {
  ConnectivityNotifier() {
    Connectivity().checkConnectivity().then(_applyBatch);
    _sub = Connectivity().onConnectivityChanged.listen(_applyBatch);
  }

  late final StreamSubscription<List<ConnectivityResult>> _sub;

  bool offline = false;

  void _applyBatch(List<ConnectivityResult> batch) {
    final next =
        batch.isNotEmpty && batch.every((r) => r == ConnectivityResult.none);
    if (offline != next) {
      offline = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
