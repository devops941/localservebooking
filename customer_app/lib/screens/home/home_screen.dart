import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/category_service.dart';
import '../../core/services/provider_service.dart';
import '../../core/services/booking_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/provider_card.dart';
import '../../core/utils/responsive.dart';
import '../categories/categories_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../profile/profile_screen.dart';
import '../areas/area_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().loadCategories();
      context.read<ProviderService>().loadAreas();
      context.read<BookingService>().loadBookings();
      context.read<NotificationService>().loadNotifications();
      context.read<NotificationService>().startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _HomeDashboard(
            onCategoriesTab: () => setState(() => _currentTabIndex = 1),
          ),
          const CategoriesScreen(isTab: true),
          const MyBookingsScreen(isTab: true),
          const ProfileScreen(isTab: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final VoidCallback onCategoriesTab;

  const _HomeDashboard({required this.onCategoriesTab});

  @override
  Widget build(BuildContext context) {
    final categoryService = context.watch<CategoryService>();
    final providerService = context.watch<ProviderService>();
    final categories = categoryService.categories;
    final featuredProviders = providerService.providers.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: InkWell(
          onTap: () async {
            final providerService = context.read<ProviderService>();
            final selected = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (context) => const AreaSelectionScreen()),
            );
            if (selected != null) {
              providerService.setSelectedArea(selected);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR LOCATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: context.watch<ProviderService>().selectedArea.isEmpty
                        ? Colors.grey.shade400
                        : const Color(0xFF1E88E5),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.watch<ProviderService>().selectedArea.isEmpty
                        ? 'Select your area'
                        : context.watch<ProviderService>().selectedArea,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.watch<ProviderService>().selectedArea.isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Consumer<NotificationService>(
            builder: (context, notifService, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                  if (notifService.unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 6,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            notifService.unreadCount > 99
                                ? '99+'
                                : '${notifService.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<CategoryService>().loadCategories(),
            context.read<ProviderService>().loadProviders(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: context.sw * 0.042, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/providers'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF1E88E5), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search electrician, plumber, AC repair...',
                          style: TextStyle(fontSize: context.rsp(14), color: Colors.grey.shade400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Promo banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SPECIAL OFFER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Flat 20% OFF on First Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rsp(15),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use coupon code: LOCAL20',
                            style: TextStyle(color: Colors.white70, fontSize: context.rsp(11.5)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/providers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Categories section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Categories',
                    style: TextStyle(
                      fontSize: context.rsp(17),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  TextButton(
                    onPressed: onCategoriesTab,
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (categoryService.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ))
              else if (categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    categoryService.error ?? 'No categories available.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isSmallPhone ? 3 : 4,
                    crossAxisSpacing: context.isSmallPhone ? 6.0 : 8.0,
                    mainAxisSpacing: context.isSmallPhone ? 8.0 : 10.0,
                    childAspectRatio: context.isSmallPhone ? 0.75 : 0.68,
                  ),
                  itemCount: categories.take(8).length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/providers',
                          arguments: {'categoryId': cat.id, 'categoryName': cat.name},
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: context.rpx(52),
                            height: context.rpx(52),
                            decoration: BoxDecoration(
                              color: cat.themeColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat.icon, color: cat.themeColor, size: context.rpx(26)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.rsp(11),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 14),

              // Top providers section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      providerService.selectedArea.isEmpty
                          ? 'Nearby Specialists'
                          : 'Specialists in ${providerService.selectedArea.split(',')[0]}',
                      style: TextStyle(
                        fontSize: context.rsp(17),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/providers'),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (providerService.selectedArea.isEmpty)
                // ── No area selected yet ──
                GestureDetector(
                  onTap: () async {
                    final ps = context.read<ProviderService>();
                    final selected = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AreaSelectionScreen()),
                    );
                    if (selected != null) ps.setSelectedArea(selected);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_searching_rounded,
                              size: 36, color: Color(0xFF1E88E5)),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Select Your Area to Find Providers',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap on your location above or the button below to choose your area in Madurai and see verified service providers near you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.my_location_rounded, size: 16),
                          label: const Text('Tap location above to select area'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (providerService.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (featuredProviders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_search_rounded,
                            size: 36, color: Color(0xFF1E88E5)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Providers in ${providerService.selectedArea.split(',')[0]}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No verified specialists are listed for this area yet. Try another locality in Madurai.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final ps = context.read<ProviderService>();
                          final selected = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AreaSelectionScreen()),
                          );
                          if (selected != null) ps.setSelectedArea(selected);
                        },
                        icon: const Icon(Icons.location_on_rounded, size: 16),
                        label: const Text('Change Area'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E88E5),
                          side: const BorderSide(color: Color(0xFF1E88E5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...featuredProviders.map((p) => ProviderCard(provider: p)),

              const SizedBox(height: 14),

              // Trust markers
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'The LocalServe Guarantee',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTrustItem(
                        Icons.verified_user_outlined, '100% Background-checked Professionals', context),
                    const SizedBox(height: 6),
                    _buildTrustItem(
                        Icons.currency_rupee, 'Transparent Upfront Pricing - No Hidden Costs', context),
                    const SizedBox(height: 6),
                    _buildTrustItem(
                        Icons.restart_alt_outlined, 'Service Re-work Guarantee if Not Satisfied', context),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green.shade700),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: context.rsp(13),
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
