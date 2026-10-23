import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized API Client matching all 13 REST Endpoints
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'http://localhost:5000/api';
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers({bool withAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ---------------------------------------------------------------------------
  // 1. POST /api/auth/register - Create customer/provider account
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'customer',
    String? profession,
    String? area,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };
    if (profession != null) payload['profession'] = profession;
    if (area != null) payload['area'] = area;

    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201 && data['data'] != null && data['data']['token'] != null) {
      _authToken = data['data']['token'] as String?;
    }
    return data;
  }

  // ---------------------------------------------------------------------------
  // 2. POST /api/auth/login - Authenticate user
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['data'] != null && data['data']['token'] != null) {
      _authToken = data['data']['token'] as String?;
    }
    return data;
  }

  // ---------------------------------------------------------------------------
  // 3. GET /api/categories - List active categories
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url, headers: _headers(withAuth: false));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 4. GET /api/areas - List supported areas
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getAreas({String? city, String? search}) async {
    final queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (search != null) queryParams['search'] = search;

    final url = Uri.parse('$baseUrl/areas').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await http.get(url, headers: _headers(withAuth: false));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 5. GET /api/providers?categoryId=&areaId= - Search approved providers
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getProviders({
    String? categoryId,
    String? areaId,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;
    if (areaId != null && areaId.isNotEmpty) queryParams['areaId'] = areaId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final url = Uri.parse('$baseUrl/providers').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await http.get(url, headers: _headers(withAuth: false));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 6. GET /api/providers/:id - Provider details
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getProviderDetails(String id) async {
    final url = Uri.parse('$baseUrl/providers/$id');
    final response = await http.get(url, headers: _headers(withAuth: false));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 7. POST /api/bookings - Create booking (customer)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createBooking({
    required String providerId,
    required String serviceTitle,
    required String categoryName,
    required DateTime bookingDate,
    required String timeSlot,
    required double totalAmount,
    required Map<String, dynamic> address,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/bookings');
    final payload = <String, dynamic>{
      'providerId': providerId,
      'serviceTitle': serviceTitle,
      'categoryName': categoryName,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'totalAmount': totalAmount,
      'address': address,
    };
    if (notes != null) payload['notes'] = notes;

    final response = await http.post(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 8. GET /api/bookings/mine - Customer booking history
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getMyBookings({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final url = Uri.parse('$baseUrl/bookings/mine').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await http.get(url, headers: _headers(withAuth: true));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 9. GET /api/provider/bookings - Provider assigned bookings
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getProviderBookings({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final url = Uri.parse('$baseUrl/provider/bookings').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await http.get(url, headers: _headers(withAuth: true));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 10. PATCH /api/bookings/:id/status - Authorized status update
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/status');
    final response = await http.patch(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 11. POST /api/reviews - Review completed booking
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> submitReview({
    required String bookingId,
    required int rating,
    String? reviewComment,
  }) async {
    final url = Uri.parse('$baseUrl/reviews');
    final payload = <String, dynamic>{
      'bookingId': bookingId,
      'rating': rating,
    };
    if (reviewComment != null) payload['reviewComment'] = reviewComment;

    final response = await http.post(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 12. PATCH /api/admin/providers/:id/approval - Approve/reject provider
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> setProviderApproval({
    required String providerId,
    required String status, // 'approved' or 'rejected'
  }) async {
    final url = Uri.parse('$baseUrl/admin/providers/$providerId/approval');
    final response = await http.patch(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // 13. POST /api/admin/categories - Create service category
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createAdminCategory({
    required String name,
    required String icon,
    String? description,
    double? startingPrice,
  }) async {
    final url = Uri.parse('$baseUrl/admin/categories');
    final payload = <String, dynamic>{
      'name': name,
      'icon': icon,
    };
    if (description != null) payload['description'] = description;
    if (startingPrice != null) payload['startingPrice'] = startingPrice;

    final response = await http.post(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
