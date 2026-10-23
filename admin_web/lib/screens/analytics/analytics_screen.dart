import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/booking_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().loadStats();
      context.read<AdminService>().loadBookings();
    });
  }

  String _fmt(dynamic val) {
    if (val == null) return '—';
    final n = num.tryParse(val.toString());
    if (n == null) return val.toString();
    if (n >= 1000000) return '₹${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000) return '₹${(n / 1000).toStringAsFixed(1)}K';
    return '₹${n.toStringAsFixed(0)}';
  }

  String _monthAbbr(int month) {
    const a = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return a[(month - 1) % 12];
  }

  List<Map<String, dynamic>> _getDailyData(List<BookingModel> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <Map<String, dynamic>>[];
    const int count = 7;
    const int stepDays = 4;
    for (int idx = count - 1; idx >= 0; idx--) {
      final targetDate = today.subtract(Duration(days: idx * stepDays));
      final nextDate = targetDate.add(const Duration(days: stepDays));

      final matched = bookings.where((b) {
        final bDate = DateTime(b.bookingDate.year, b.bookingDate.month, b.bookingDate.day);
        return !bDate.isBefore(targetDate) && bDate.isBefore(nextDate);
      }).toList();

      final gross = matched.fold<double>(0, (s, b) => s + b.totalAmount);
      result.add({
        'label': '${targetDate.day} ${_monthAbbr(targetDate.month)}',
        'gross': gross,
        'commission': gross * 0.15,
      });
    }
    return result;
  }

  List<Map<String, dynamic>> _getMonthlyData(List<BookingModel> bookings) {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);
      final mb = bookings.where((b) =>
          !b.bookingDate.isBefore(month) && b.bookingDate.isBefore(nextMonth)).toList();
      final gross = mb.fold<double>(0, (s, b) => s + b.totalAmount);
      result.add({
        'label': _monthAbbr(month.month),
        'gross': gross,
        'commission': gross * 0.15,
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdminService>();
    final stats = svc.stats;
    final bookings = svc.bookings;

    if (svc.isLoading && stats.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)));
    }
    if (svc.error != null && stats.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(svc.error!, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AdminService>().loadStats();
              context.read<AdminService>().loadBookings();
            },
            child: const Text('Retry'),
          ),
        ]),
      );
    }

    final gross = (stats['grossVolume'] as num?)?.toDouble() ?? 0;
    final commission = (stats['platformCommission'] as num?)?.toDouble() ?? 0;
    final completedBookings = (stats['completedBookings'] as num?)?.toInt() ?? 0;
    final totalBookings = (stats['totalBookings'] as num?)?.toInt() ?? 0;
    final activeBookings = (stats['activeBookings'] as num?)?.toInt() ?? 0;
    final cancelledBookings = (stats['cancelledBookings'] as num?)?.toInt() ?? 0;
    final providerPayouts = gross - commission;
    final commissionRate = gross > 0 ? commission / gross : 0.15;

    final dailyData = _getDailyData(bookings);
    final monthlyData = _getMonthlyData(bookings);
    final recentBookings = bookings.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(svc),
          const SizedBox(height: 24),
          _buildMetricCards(gross, commission, completedBookings, providerPayouts),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, con) {
            if (con.maxWidth > 800) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 3, child: _buildRevenueLineChart(dailyData)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildBookingStatusDonut(totalBookings, completedBookings, activeBookings, cancelledBookings)),
              ]);
            }
            return Column(children: [
              _buildRevenueLineChart(dailyData),
              const SizedBox(height: 16),
              _buildBookingStatusDonut(totalBookings, completedBookings, activeBookings, cancelledBookings),
            ]);
          }),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, con) {
            if (con.maxWidth > 800) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 2, child: _buildMonthlyLineChart(monthlyData)),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: _buildRecentTransactions(recentBookings, commissionRate)),
              ]);
            }
            return Column(children: [
              _buildMonthlyLineChart(monthlyData),
              const SizedBox(height: 16),
              _buildRecentTransactions(recentBookings, commissionRate),
            ]);
          }),
          const SizedBox(height: 16),
          _buildRevenueSummaryBar(gross, commission, providerPayouts, totalBookings),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminService svc) {
    return Row(
      children: [
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Revenue Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            SizedBox(height: 3),
            Text('Track your platform performance and revenue insights', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ]),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6B7280)),
            SizedBox(width: 6),
            Text('Last 30 Days', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
            SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF6B7280)),
          ]),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_rounded, size: 14),
          label: const Text('Export Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
        if (svc.isLoading)
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E88E5))),
          ),
      ],
    );
  }

  Widget _buildMetricCards(double gross, double commission, int completedBookings, double payouts) {
    final cards = [
      _CardData(
        title: 'Gross Booking Volume', value: _fmt(gross), change: '+12.5%',
        subtitle: 'vs. previous 30 days', color: const Color(0xFF1E88E5),
        icon: Icons.bar_chart_rounded,
        sparkData: [850,900,820,950,1100,980,1200,1100,1300,1250],
      ),
      _CardData(
        title: 'Platform Commission', value: _fmt(commission), change: '+8.2%',
        subtitle: 'vs. previous 30 days', color: const Color(0xFF10B981),
        icon: Icons.percent_rounded,
        sparkData: [120,140,130,150,160,145,170,155,180,175],
      ),
      _CardData(
        title: 'Completed Bookings', value: completedBookings.toString(), change: '+15.0%',
        subtitle: 'vs. previous 30 days', color: const Color(0xFF8B5CF6),
        icon: Icons.task_alt_rounded,
        sparkData: [3,4,3,5,4,6,5,7,6,8],
      ),
      _CardData(
        title: 'Provider Payouts', value: _fmt(payouts), change: '+11.3%',
        subtitle: 'vs. previous 30 days', color: const Color(0xFFF59E0B),
        icon: Icons.account_balance_wallet_outlined,
        sparkData: [700,760,690,800,950,830,1020,945,1100,1060],
      ),
    ];

    return Row(
      children: cards.asMap().entries.map((entry) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: entry.key < cards.length - 1 ? 14 : 0),
          child: _MetricCard(data: entry.value),
        ),
      )).toList(),
    );
  }

  Widget _buildRevenueLineChart(List<Map<String, dynamic>> dailyData) {
    final hasRealBookings = dailyData.any((d) => ((d['gross'] as num?)?.toDouble() ?? 0) > 0);
    final sampleDaily = [950.0, 1100.0, 1020.0, 1450.0, 1800.0, 1650.0, 2400.0];

    final grossSpots = List<FlSpot>.generate(dailyData.length, (i) {
      final val = hasRealBookings
          ? ((dailyData[i]['gross'] as num?)?.toDouble() ?? 0.0)
          : sampleDaily[i % sampleDaily.length];
      return FlSpot(i.toDouble(), val);
    });

    final commSpots = List<FlSpot>.generate(dailyData.length, (i) {
      final val = hasRealBookings
          ? ((dailyData[i]['commission'] as num?)?.toDouble() ?? 0.0)
          : (sampleDaily[i % sampleDaily.length] * 0.15);
      return FlSpot(i.toDouble(), val);
    });

    final maxGross = grossSpots.map((s) => s.y).fold<double>(0.0, math.max);
    final maxComm = commSpots.map((s) => s.y).fold<double>(0.0, math.max);
    final peak = math.max(maxGross, maxComm);
    final double maxY = peak <= 1000
        ? 1500.0
        : ((peak * 1.25 / 500).ceil() * 500.0);
    final double yInterval = (maxY / 4).clamp(200.0, 50000.0);

    return _SectionCard(
      title: 'Revenue Overview',
      subtitle: 'Gross booking volume vs Platform commission (Last 30 days)',
      legendItems: const [
        _LegendItem(color: Color(0xFF2563EB), label: 'Gross Booking Volume'),
        _LegendItem(color: Color(0xFF10B981), label: 'Platform Commission'),
      ],
      child: SizedBox(
        height: 230,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFF1F5F9),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: yInterval,
                    getTitlesWidget: (val, _) {
                      if (val < 0) return const SizedBox.shrink();
                      String txt;
                      if (val >= 1000000) {
                        txt = '₹${(val / 1000000).toStringAsFixed(1)}M';
                      } else if (val >= 1000) {
                        txt = '₹${(val / 1000).toStringAsFixed(0)}K';
                      } else {
                        txt = '₹${val.toInt()}';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          txt,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (val, _) {
                      final idx = val.round();
                      if ((val - idx).abs() > 0.05) return const SizedBox.shrink();
                      if (idx < 0 || idx >= dailyData.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dailyData[idx]['label'] as String,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (dailyData.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E293B),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isGross = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isGross ? "Gross" : "Comm"}: ₹${spot.y.toStringAsFixed(0)}',
                        TextStyle(
                          color: isGross ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: grossSpots,
                  isCurved: true,
                  curveSmoothness: 0.22,
                  preventCurveOverShooting: true,
                  color: const Color(0xFF2563EB),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF2563EB),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2563EB).withValues(alpha: 0.15),
                        const Color(0xFF2563EB).withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: commSpots,
                  isCurved: true,
                  curveSmoothness: 0.22,
                  preventCurveOverShooting: true,
                  color: const Color(0xFF10B981),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF10B981),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.12),
                        const Color(0xFF10B981).withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingStatusDonut(int total, int completed, int active, int cancelled) {
    final safeTotal = total > 0 ? total : 1;
    final compPct = completed / safeTotal * 100;
    final activePct = active / safeTotal * 100;
    final cancelPct = cancelled / safeTotal * 100;

    final displayTotal = total > 0 ? total : 32;
    final displayComp = total > 0 ? completed : 24;
    final displayActive = total > 0 ? active : 5;
    final displayCancel = total > 0 ? cancelled : 3;
    final displayCompPct = total > 0 ? compPct.toInt() : 75;
    final displayActivePct = total > 0 ? activePct.toInt() : 15;
    final displayCancelPct = total > 0 ? cancelPct.toInt() : 10;

    final sections = total == 0
        ? [
            PieChartSectionData(value: 75, color: const Color(0xFF10B981), radius: 42, showTitle: false),
            PieChartSectionData(value: 15, color: const Color(0xFF1E88E5), radius: 42, showTitle: false),
            PieChartSectionData(value: 10, color: const Color(0xFFEF4444), radius: 42, showTitle: false),
          ]
        : [
            PieChartSectionData(value: compPct > 0 ? compPct : 0.1, color: const Color(0xFF10B981), radius: 42, showTitle: false),
            PieChartSectionData(value: activePct > 0 ? activePct : 0.1, color: const Color(0xFF1E88E5), radius: 42, showTitle: false),
            PieChartSectionData(value: cancelPct > 0 ? cancelPct : 0.1, color: const Color(0xFFEF4444), radius: 42, showTitle: false),
          ];

    return _SectionCard(
      title: 'Booking Status',
      subtitle: 'Booking distribution (Last 30 days)',
      child: Column(children: [
        SizedBox(
          height: 200,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(PieChartData(
              sections: sections,
              centerSpaceRadius: 62,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$displayTotal', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const Text('Total Bookings', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        _legendRow(const Color(0xFF10B981), 'Completed', displayCompPct, displayComp),
        const SizedBox(height: 8),
        _legendRow(const Color(0xFF1E88E5), 'Active', displayActivePct, displayActive),
        const SizedBox(height: 8),
        _legendRow(const Color(0xFFEF4444), 'Cancelled', displayCancelPct, displayCancel),
      ]),
    );
  }

  Widget _legendRow(Color color, String label, int pct, int count) {
    return Row(children: [
      CircleAvatar(radius: 6, backgroundColor: color),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      Text('$pct%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Text('($count)', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ]);
  }

  Widget _buildMonthlyLineChart(List<Map<String, dynamic>> monthlyData) {
    final hasRealBookings = monthlyData.any((d) => ((d['gross'] as num?)?.toDouble() ?? 0) > 0);
    final sampleMonthly = [2500.0, 3200.0, 4100.0, 4800.0, 5600.0, 7200.0];

    final grossSpots = List<FlSpot>.generate(monthlyData.length, (i) {
      final val = hasRealBookings
          ? ((monthlyData[i]['gross'] as num?)?.toDouble() ?? 0.0)
          : sampleMonthly[i % sampleMonthly.length];
      return FlSpot(i.toDouble(), val);
    });

    final commSpots = List<FlSpot>.generate(monthlyData.length, (i) {
      final val = hasRealBookings
          ? ((monthlyData[i]['commission'] as num?)?.toDouble() ?? 0.0)
          : (sampleMonthly[i % sampleMonthly.length] * 0.15);
      return FlSpot(i.toDouble(), val);
    });

    final maxGross = grossSpots.map((s) => s.y).fold<double>(0.0, math.max);
    final maxComm = commSpots.map((s) => s.y).fold<double>(0.0, math.max);
    final peak = math.max(maxGross, maxComm);
    final double maxY = peak <= 1000
        ? 1500.0
        : ((peak * 1.25 / 500).ceil() * 500.0);
    final double yInterval = (maxY / 4).clamp(200.0, 50000.0);

    return _SectionCard(
      title: 'Monthly Revenue',
      subtitle: 'Gross booking volume (₹) vs Commission',
      legendItems: const [
        _LegendItem(color: Color(0xFF2563EB), label: 'Gross Booking Volume'),
        _LegendItem(color: Color(0xFF10B981), label: 'Commission'),
      ],
      child: SizedBox(
        height: 230,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFF1F5F9),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: yInterval,
                    getTitlesWidget: (val, _) {
                      if (val < 0) return const SizedBox.shrink();
                      String txt;
                      if (val >= 1000000) {
                        txt = '₹${(val / 1000000).toStringAsFixed(1)}M';
                      } else if (val >= 1000) {
                        txt = '₹${(val / 1000).toStringAsFixed(0)}K';
                      } else {
                        txt = '₹${val.toInt()}';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          txt,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (val, _) {
                      final idx = val.round();
                      if ((val - idx).abs() > 0.05) return const SizedBox.shrink();
                      if (idx < 0 || idx >= monthlyData.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          monthlyData[idx]['label'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (monthlyData.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E293B),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isGross = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isGross ? "Gross" : "Comm"}: ₹${spot.y.toStringAsFixed(0)}',
                        TextStyle(
                          color: isGross ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: grossSpots,
                  isCurved: true,
                  curveSmoothness: 0.22,
                  preventCurveOverShooting: true,
                  color: const Color(0xFF2563EB),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3.5,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF2563EB),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2563EB).withValues(alpha: 0.15),
                        const Color(0xFF2563EB).withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: commSpots,
                  isCurved: true,
                  curveSmoothness: 0.22,
                  preventCurveOverShooting: true,
                  color: const Color(0xFF10B981),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3.5,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF10B981),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.12),
                        const Color(0xFF10B981).withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<BookingModel> bookings, double commissionRate) {
    return _SectionCard(
      title: 'Recent Transactions',
      action: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF1E88E5)),
        label: const Text('View All', style: TextStyle(fontSize: 12, color: Color(0xFF1E88E5))),
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: const Row(children: [
            Expanded(flex: 2, child: Text('Booking ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            SizedBox(width: 8),
            Expanded(flex: 3, child: Text('Service Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            SizedBox(width: 8),
            Expanded(flex: 2, child: Text('Booking Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            SizedBox(width: 8),
            Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            SizedBox(width: 8),
            Expanded(flex: 2, child: Text('Commission', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            SizedBox(width: 8),
            Expanded(flex: 2, child: Text('Payout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            SizedBox(width: 8),
            Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
          ]),
        ),
        if (bookings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No recent transactions', style: TextStyle(color: Colors.grey))),
          )
        else
          ...bookings.map((b) {
            final comm = b.totalAmount * commissionRate;
            final payout = b.totalAmount - comm;
            final bId = b.id.length > 6
                ? '#LSB${b.id.substring(b.id.length - 6).toUpperCase()}'
                : '#${b.id}';
            final dateStr = '${b.bookingDate.day} ${_monthAbbr(b.bookingDate.month)} ${b.bookingDate.year}';

            final Color sBg;
            final Color sColor;
            final String sLabel;
            switch (b.status.toLowerCase()) {
              case 'completed':
                sBg = const Color(0xFFECFDF5); sColor = const Color(0xFF065F46); sLabel = 'Completed';
              case 'cancelled':
                sBg = const Color(0xFFFEF2F2); sColor = const Color(0xFF991B1B); sLabel = 'Cancelled';
              case 'inprogress':
              case 'in_progress':
                sBg = const Color(0xFFEFF6FF); sColor = const Color(0xFF1E40AF); sLabel = 'Active';
              default:
                sBg = const Color(0xFFFFFBEB); sColor = const Color(0xFF92400E); sLabel = 'Pending';
            }

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
              child: Row(children: [
                Expanded(flex: 2, child: Text(bId, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                const SizedBox(width: 8),
                Expanded(flex: 3, child: Text(
                  b.serviceTitle.length > 18 ? '${b.serviceTitle.substring(0, 16)}…' : b.serviceTitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                )),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Text(dateStr, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)))),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Text('₹${b.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Text('₹${comm.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Text('₹${payout.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: sBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(sLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sColor)),
                )),
              ]),
            );
          }),
      ]),
    );
  }

  Widget _buildRevenueSummaryBar(double gross, double commission, double payouts, int totalBookings) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        _revSumStat('Total Revenue (30 Days)', _fmt(gross), '+12.5%', Icons.trending_up_rounded, const Color(0xFF1E88E5)),
        _divV(),
        _revSumStat('Total Commission', _fmt(commission), '+8.2%', Icons.account_balance_outlined, const Color(0xFF10B981)),
        _divV(),
        _revSumStat('Total Bookings', totalBookings.toString(), '+15.0%', Icons.calendar_month_outlined, const Color(0xFF8B5CF6)),
        _divV(),
        _revSumStat('Provider Payouts', _fmt(payouts), '+11.3%', Icons.payments_outlined, const Color(0xFFF59E0B)),
      ]),
    );
  }

  Widget _divV() => Container(
    width: 1, height: 50,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: const Color(0xFFE5E7EB),
  );

  Widget _revSumStat(String label, String value, String change, IconData icon, Color color) {
    return Expanded(child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: color),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        const SizedBox(height: 2),
        Row(children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const SizedBox(width: 6),
          Text(change, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
        ]),
      ]),
    ]));
  }
}

class _CardData {
  final String title, value, change, subtitle;
  final Color color;
  final IconData icon;
  final List<double> sparkData;
  const _CardData({
    required this.title, required this.value, required this.change,
    required this.subtitle, required this.color, required this.icon, required this.sparkData,
  });
}

class _MetricCard extends StatelessWidget {
  final _CardData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(data.title, style: TextStyle(fontSize: 12, color: data.color, fontWeight: FontWeight.w700))),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: data.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(data.icon, color: data.color, size: 16),
          ),
        ]),
        const SizedBox(height: 10),
        Text(data.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        const SizedBox(height: 6),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
            child: Text(data.change, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(data.subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)))),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: CustomPaint(
            size: const Size(double.infinity, 40),
            painter: _SparklinePainter(data.sparkData, data.color),
          ),
        ),
      ]),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = maxVal - minVal;
    if (range == 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - (data[i] - minVal) / range * size.height * 0.85 - size.height * 0.05;
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendItem {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<_LegendItem>? legendItems;
  final Widget? action;

  const _SectionCard({
    required this.title, required this.child,
    this.subtitle, this.legendItems, this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ])),
          if (action != null) action!,
          if (legendItems != null)
            Row(children: legendItems!.map((item) => Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(radius: 4, backgroundColor: item.color),
                const SizedBox(width: 4),
                Text(item.label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              ]),
            )).toList()),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}
