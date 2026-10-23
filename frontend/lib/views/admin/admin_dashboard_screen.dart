import 'package:flutter/material.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/booking_service.dart';
import '../shared/role_selector_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_users_screen.dart';
import 'admin_verifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedSidebarIndex = 0;
  final bookingService = BookingService();

  final List<String> _menuTitles = [
    'Dashboard Overview',
    'User Management',
    'Provider KYC Approvals',
    'Service Categories',
    'Platform Bookings',
    'Revenue Analytics',
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.verified_user_outlined,
    Icons.category_outlined,
    Icons.assignment_outlined,
    Icons.bar_chart_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // Left Sidebar (Web View navigation)
          Container(
            width: 260,
            color: const Color(0xFF0F172A), // Modern dark slate web sidebar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.home_repair_service, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LocalServe',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Admin Web Portal',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'PORTAL MANAGEMENT',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuTitles.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedSidebarIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        child: InkWell(
                          onTap: () => setState(() => _selectedSidebarIndex = index),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1E88E5)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _menuIcons[index],
                                  color: isSelected ? Colors.white : Colors.white60,
                                  size: 19,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _menuTitles[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (index == 2)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('2', style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Switch Module Link
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Switch Experience',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const RoleSelectorScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.phone_android, size: 16),
                          label: const Text('Open Mobile App', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Body Content
          Expanded(
            child: Column(
              children: [
                // Top Web Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _menuTitles[_selectedSidebarIndex],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(radius: 4, backgroundColor: Colors.green),
                                SizedBox(width: 6),
                                Text(
                                  'MongoDB Backend: Online',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF1E88E5),
                            child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Super Admin',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Dynamic View by Index
                Expanded(
                  child: _buildSelectedView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedSidebarIndex) {
      case 0:
        return _buildDashboardOverview();
      case 1:
        return const AdminUsersScreen(isEmbedded: true);
      case 2:
        return const AdminVerificationsScreen(isEmbedded: true);
      case 3:
        return const AdminCategoriesScreen(isEmbedded: true);
      case 4:
        return const AdminBookingsScreen(isEmbedded: true);
      case 5:
        return const AdminAnalyticsScreen(isEmbedded: true);
      default:
        return _buildDashboardOverview();
    }
  }

  Widget _buildDashboardOverview() {
    final bookings = bookingService.bookings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Metric cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Platform Gross GMV',
                  '₹2,48,500',
                  '+18.4% vs last month',
                  Icons.currency_rupee,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Admin Commission (15%)',
                  '₹37,275',
                  '+16.2% net margin',
                  Icons.account_balance_wallet_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Registered Users',
                  '4,850',
                  '4,708 Cust • 142 Pros',
                  Icons.people_outline,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Live Active Bookings',
                  '${bookings.where((b) => b.status == BookingStatus.confirmed).length}',
                  '3 in progress currently',
                  Icons.assignment_turned_in_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Provider Approval Alert Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.amber, size: 28),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2 New Provider KYC Applications Require Review',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF92400E)),
                      ),
                      Text(
                        'Rajesh Khanna (Painter) & Kabilan Murugan (AC Mechanic) submitted identification documents.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedSidebarIndex = 2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Review Applications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Bookings Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Platform Bookings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedSidebarIndex = 4),
                        child: const Text('View All Bookings', style: TextStyle(color: Color(0xFF1E88E5))),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('SERVICE & PRO', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('DATE & TIME', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('COMMISSION', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: bookings.take(5).map((b) {
                      return DataRow(
                        cells: [
                          DataCell(Text('#${b.id}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(b.customerName)),
                          DataCell(Text('${b.serviceTitle}\nby ${b.providerName}', style: const TextStyle(fontSize: 12))),
                          DataCell(Text('${b.bookingDate.day}/${b.bookingDate.month} • ${b.timeSlot}', style: const TextStyle(fontSize: 12))),
                          DataCell(Text('₹${b.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('₹${(b.totalAmount * 0.15).toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: b.status.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                b.status.label,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: b.status.color),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
