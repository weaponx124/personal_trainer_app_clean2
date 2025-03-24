import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  bool _isOnline = true;

  NetworkService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  bool get isOnline => _isOnline;

  Future<void> _initConnectivity() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);
    } catch (e) {
      print('NetworkService: Error initializing connectivity: $e');
      _isOnline = false;
      _connectionStatusController.add(_isOnline);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;
    print('NetworkService: Connection status updated: $_isOnline');
    _connectionStatusController.add(_isOnline);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}