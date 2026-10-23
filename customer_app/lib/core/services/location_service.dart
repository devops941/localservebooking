import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Returns current city string for display (home screen header).
  static Future<String> getCurrentCity() async {
    try {
      final position = await _getPermittedPosition();
      if (position == null) return 'Enable GPS';

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? p.subAdministrativeArea ?? '';
        final state = p.administrativeArea ?? '';
        return city.isNotEmpty ? '$city, $state' : state;
      }
      return 'Unknown Location';
    } catch (_) {
      return 'Kalavasal, Madurai';
    }
  }

  /// Returns the raw GPS Position with lat/lng (used when creating a booking).
  static Future<Position?> getCurrentPosition() async {
    try {
      return await _getPermittedPosition();
    } catch (_) {
      return null;
    }
  }

  /// Shared permission + position logic.
  static Future<Position?> _getPermittedPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Stream for continuous live tracking (used by provider app).
  static Stream<Position> livePositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // emit every 10 metres
      ),
    );
  }
}
