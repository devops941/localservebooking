import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;

/// Emits provider GPS to the backend via Socket.IO while a job is in progress.
class LocationTrackingService {
  sio.Socket? _socket;
  StreamSubscription<Position>? _positionSub;
  String? _activeBookingId;
  bool get isTracking => _positionSub != null;

  // Derive socket URL from API base (strip /api suffix)
  static const String _socketUrl = 'http://192.168.1.6:5000';

  Future<void> startTracking(String bookingId) async {
    if (isTracking) await stopTracking();

    // Check & request permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _activeBookingId = bookingId;

    // Connect Socket.IO
    _socket = sio.io(
      _socketUrl,
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    _socket!.connect();
    _socket!.onConnect((_) => _socket!.emit('join:booking', bookingId));

    // Stream GPS and emit every 10 metres
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      if (_socket?.connected == true) {
        _socket!.emit('provider:location', {
          'bookingId': _activeBookingId,
          'lat': pos.latitude,
          'lng': pos.longitude,
        });
      }
    });
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    if (_socket?.connected == true) {
      _socket!.emit('leave:booking', _activeBookingId);
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _activeBookingId = null;
  }
}
