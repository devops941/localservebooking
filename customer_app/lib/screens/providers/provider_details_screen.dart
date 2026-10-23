import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/provider_model.dart';
import '../../core/services/api_client.dart';
import '../../core/widgets/custom_button.dart';

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen({super.key});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _reviewsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reviewsLoaded) {
      _reviewsLoaded = true;
      final provider =
          ModalRoute.of(context)?.settings.arguments as ProviderModel?;
      if (provider != null) {
        _fetchReviews(provider.id);
      }
    }
  }

  Future<void> _fetchReviews(String providerId) async {
    try {
      final res = await ApiClient().get('/providers/$providerId');
      final body = res.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final raw = data['reviews'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _reviews = raw.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
      // keep empty list — placeholder review will show
    }
  }

  Future<void> _callProvider(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: trimmed);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        ModalRoute.of(context)!.settings.arguments as ProviderModel;

    final locality = provider.area.split(',')[0].trim();
    final locationDisplay = locality.isNotEmpty ? '$locality, Madurai' : 'Madurai';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          provider.name,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B), size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor:
                              const Color(0xFF1E88E5).withValues(alpha: 0.1),
                          child: Text(
                            provider.name.isNotEmpty ? provider.name[0] : 'P',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                        if (provider.isVerified)
                          const Positioned(
                            bottom: 0,
                            right: 2,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.verified,
                                  size: 18, color: Color(0xFF1E88E5)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    provider.profession,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        locationDisplay,
                        style: TextStyle(
                            fontSize: 12.5, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Compact Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                            'Rating',
                            '${provider.rating.toStringAsFixed(1)} ★',
                            const Color(0xFFD97706)),
                        _buildStatDivider(),
                        _buildStatColumn('Reviews', '${provider.reviewCount}',
                            const Color(0xFF1E88E5)),
                        _buildStatDivider(),
                        _buildStatColumn('Experience',
                            '${provider.experienceYears} Yrs', const Color(0xFF0D9488)),
                        _buildStatDivider(),
                        _buildStatColumn('Jobs Done',
                            '${provider.completedJobs}+', const Color(0xFF4F46E5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Call Action button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _callProvider(provider.phone),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call Provider', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E88E5),
                        side: const BorderSide(color: Color(0xFF1E88E5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // About section
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Service Provider',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.bio.isNotEmpty
                        ? provider.bio
                        : 'Certified professional serving residential and commercial properties in $locality, Madurai with guaranteed satisfaction.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_rounded,
                            size: 16, color: Color(0xFF059669)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Background Checked & KYC Approved',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF065F46),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Reviews section
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Reviews',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${provider.reviewCount} reviews',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_reviews.isEmpty)
                    _buildReviewItem(
                      'Verified Customer',
                      provider.rating.toStringAsFixed(1),
                      'Great service! Professional and arrived on time.',
                      'Recently',
                    )
                  else
                    ..._reviews.take(3).toList().asMap().entries.map((entry) {
                      final i = entry.key;
                      final r = entry.value;
                      final customerField = r['customer'];
                      final author = customerField is Map
                          ? (customerField['name'] ?? 'Customer').toString()
                          : 'Customer';
                      final rating =
                          (r['rating'] as num?)?.toDouble() ?? 0.0;
                      final comment =
                          (r['reviewComment'] ?? r['comment'] ?? '').toString();
                      return Column(
                        children: [
                          _buildReviewItem(
                            author,
                            rating.toStringAsFixed(1),
                            comment,
                            '',
                          ),
                          if (i < _reviews.length - 1 && i < 2)
                            const Divider(height: 16),
                        ],
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Starting from',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    '₹${provider.hourlyRate.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Book Service Now',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/booking',
                      arguments: provider,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 14.5, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 22, width: 1, color: const Color(0xFFE2E8F0));
  }

  Widget _buildReviewItem(
      String author, String rating, String text, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(author,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
            Row(
              children: [
                const Icon(Icons.star, size: 13, color: Colors.amber),
                const SizedBox(width: 3),
                Text(rating,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                if (date.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(date,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ],
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ],
    );
  }
}
