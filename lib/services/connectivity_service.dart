import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(result);
    _connectionController.add(_isConnected);

    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        final connected = _hasConnection(result);
        if (connected != _isConnected) {
          _isConnected = connected;
          _connectionController.add(_isConnected);
        }
      },
    );
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(result);
    return _isConnected;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}
