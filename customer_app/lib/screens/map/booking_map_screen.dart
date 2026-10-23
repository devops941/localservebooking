import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import '../../core/models/booking_model.dart';
import '../../core/services/map_service.dart';
import '../../core/constants/api_constants.dart';

class BookingMapScreen extends StatefulWidget {
  const BookingMapScreen({super.key});

  @override
  State<BookingMapScreen> createState() => _BookingMapScreenState();
}

class _BookingMapScreenState extends State<BookingMapScreen> {
  final MapController _mapController = MapController();
  final MapService _mapService = MapService();

  BookingModel? _booking;
  bool _initialized = false;

  LatLng? _customerLatLng;
  LatLng? _providerLatLng;
  RouteResult? _route;

  bool _loadingRoute = false;
  bool _liveTracking = false;
  String? _error;

  sio.Socket? _socket;
  StreamSubscription? _socketSub;

  // Madurai city centre as default fallback
  static const LatLng _madurai = LatLng(9.9252, 78.1198);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _booking = ModalRoute.of(context)!.settings.arguments as BookingModel;
      _boot();
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> _boot() async {
    final b = _booking!;

    // Customer pin
    if (b.customerLat != null && b.customerLng != null) {
      _customerLatLng = LatLng(b.customerLat!, b.customerLng!);
    }

    // Connect Socket.IO and join booking room
    _connectSocket(b.id);

    // If both pins known, fetch route immediately
    if (_customerLatLng != null && _providerLatLng != null) {
      await _fetchRoute();
    } else if (_customerLatLng != null) {
      // Center on customer while waiting for provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_customerLatLng!, 14);
      });
    }

    if (mounted) setState(() {});
  }

  void _connectSocket(String bookingId) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    _socket = sio.io(
      baseUrl,
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();
    _socket!.onConnect((_) {
      _socket!.emit('join:booking', bookingId);
      if (mounted) setState(() => _liveTracking = true);
    });

    _socket!.on('provider:location:update', (data) {
      final lat = (data['lat'] as num).toDouble();
      final lng = (data['lng'] as num).toDouble();
      if (mounted) {
        setState(() => _providerLatLng = LatLng(lat, lng));
        if (_customerLatLng != null) _fetchRoute();
      }
    });

    _socket!.onDisconnect((_) {
      if (mounted) setState(() => _liveTracking = false);
    });
  }

  Future<void> _fetchRoute() async {
    if (_customerLatLng == null || _providerLatLng == null) return;
    setState(() {
      _loadingRoute = true;
      _error = null;
    });

    final result = await _mapService.getRoute(
      startLat: _providerLatLng!.latitude,
      startLng: _providerLatLng!.longitude,
      endLat: _customerLatLng!.latitude,
      endLng: _customerLatLng!.longitude,
    );

    if (mounted) {
      setState(() {
        _route = result;
        _loadingRoute = false;
        if (result == null) _error = 'Could not fetch route. Check ORS API key.';
      });
      if (result != null) _fitBounds();
    }
  }

  void _fitBounds() {
    if (_customerLatLng == null && _providerLatLng == null) return;
    final points = [
      if (_customerLatLng != null) _customerLatLng!,
      if (_providerLatLng != null) _providerLatLng!,
    ];
    if (points.length == 1) {
      _mapController.move(points.first, 14);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = _booking;
    if (b == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              b.providerName.isNotEmpty ? b.providerName : 'Provider',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2340)),
            ),
            Text(
              b.serviceTitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          // Live tracking indicator
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _liveTracking ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _liveTracking ? 'Live' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: _liveTracking ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _customerLatLng ?? _madurai,
              initialZoom: 13,
            ),
            children: [
              // OSM tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.localserve.customer',
              ),
              // Route polyline
              if (_route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route!.points,
                      strokeWidth: 4,
                      color: const Color(0xFF1565C0),
                    ),
                  ],
                ),
              // Markers
              MarkerLayer(
                markers: [
                  // Customer location (blue)
                  if (_customerLatLng != null)
                    Marker(
                      point: _customerLatLng!,
                      width: 44,
                      height: 44,
                      child: _buildMarker(
                        icon: Icons.home_rounded,
                        color: const Color(0xFF1565C0),
                        label: 'You',
                      ),
                    ),
                  // Provider live location (orange)
                  if (_providerLatLng != null)
                    Marker(
                      point: _providerLatLng!,
                      width: 44,
                      height: 44,
                      child: _buildMarker(
                        icon: Icons.engineering_rounded,
                        color: Colors.orange.shade700,
                        label: 'Provider',
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Error banner
          if (_error != null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.red)),
              ),
            ),

          // Loading spinner for route
          if (_loadingRoute)
            const Center(child: CircularProgressIndicator()),

          // Bottom info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCard(b),
          ),

          // Fit-bounds FAB
          Positioned(
            bottom: _route != null ? 190 : 150,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1565C0),
              tooltip: 'Fit map',
              onPressed: _fitBounds,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBottomCard(BookingModel b) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status chip
          Row(
            children: [
              Icon(b.status.icon, size: 16, color: b.status.color),
              const SizedBox(width: 6),
              Text(b.status.label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: b.status.color)),
              const Spacer(),
              if (_liveTracking)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                      const SizedBox(width: 4),
                      const Text('Live Tracking', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 16),

          // Distance & ETA row
          if (_route != null) ...[
            Row(
              children: [
                _infoTile(Icons.straighten_rounded, '${_route!.distanceKm} km', 'Distance'),
                const SizedBox(width: 12),
                _infoTile(Icons.access_time_rounded, '${_route!.durationMin} min', 'Est. Time'),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadingRoute ? null : _fetchRoute,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          // No location info
          if (_customerLatLng == null) ...[
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Location not saved for this booking. New bookings will include GPS.',
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (_providerLatLng == null && _customerLatLng != null) ...[
            Row(
              children: [
                const Icon(Icons.location_searching_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Waiting for provider to share live location...',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Legend
          Row(
            children: [
              _legendDot(const Color(0xFF1565C0), 'Your Location'),
              const SizedBox(width: 16),
              _legendDot(Colors.orange.shade700, 'Provider'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF1565C0)),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2340))),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
