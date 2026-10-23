import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'api_client.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final int durationMin;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });
}

class MapService {
  final ApiClient _api = ApiClient();

  /// Fetches a driving route via the backend ORS proxy.
  /// Returns null on error.
  Future<RouteResult?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final res = await _api.get(
        '/map/route',
        queryParameters: {
          'startLat': startLat.toString(),
          'startLng': startLng.toString(),
          'endLat': endLat.toString(),
          'endLng': endLng.toString(),
        },
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final rawPoints = data['route'] as List;
      final points = rawPoints.map((p) {
        return LatLng(
          (p['lat'] as num).toDouble(),
          (p['lng'] as num).toDouble(),
        );
      }).toList();

      return RouteResult(
        points: points,
        distanceKm: double.parse(data['distance_km'].toString()),
        durationMin: data['duration_min'] as int,
      );
    } on DioException {
      return null;
    }
  }
}
