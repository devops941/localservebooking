import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/responsive.dart';

class KycPendingScreen extends StatefulWidget {
  const KycPendingScreen({super.key});

  @override
  State<KycPendingScreen> createState() => _KycPendingScreenState();
}

class _KycPendingScreenState extends State<KycPendingScreen> {
  Timer? _pollTimer;
  bool _isChecking = false;
  int _secondsUntilNextCheck = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Auto-check every 30 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkVerificationStatus();
    });
    // Countdown display
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsUntilNextCheck--;
        if (_secondsUntilNextCheck <= 0) _secondsUntilNextCheck = 30;
      });
    });
  }

  Future<void> _checkVerificationStatus({bool manual = false}) async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      if (manual) _secondsUntilNextCheck = 30;
    });

    final authService = context.read<AuthService>();
    final justVerified = await authService.refreshProfile();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (justVerified) {
      _pollTimer?.cancel();
      _countdownTimer?.cancel();
      _navigateToHome();
    } else if (manual) {
      // Show brief feedback for manual check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded,
                  color: Colors.white, size: 16),
              SizedBox(width: 10),
              Text('Still under review. We\'ll notify you once approved.'),
            ],
          ),
          backgroundColor: const Color(0xFF00897B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final name = authService.currentUser?.name ?? 'Service Professional';
    final firstName = name.split(' ').first;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF00897B),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Compact green header ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.sw * 0.05, 12, context.sw * 0.05, 18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.handyman_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LocalServe',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rsp(15),
                                fontWeight: FontWeight.bold)),
                        Text('Partner Portal',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: context.rsp(11))),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        authService.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // ── White body ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        context.sw * 0.05, 28, context.sw * 0.05, 24),
                    child: Column(
                      children: [
                        // ── Status icon ──
                        Container(
                          width: context.rpx(80),
                          height: context.rpx(80),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.amber.shade200, width: 2),
                          ),
                          child: Center(
                            child: Icon(Icons.hourglass_top_rounded,
                                color: Colors.amber.shade600,
                                size: context.rpx(38)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── Status badge ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 13,
                                  color: Colors.amber.shade800),
                              const SizedBox(width: 5),
                              Text('UNDER REVIEW',
                                  style: TextStyle(
                                      fontSize: context.rsp(11),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                      letterSpacing: 0.6)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text('Application Submitted!',
                            style: TextStyle(
                                fontSize: context.rsp(22),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937))),
                        const SizedBox(height: 8),
                        Text(
                          'Hi $firstName, thank you for joining LocalServe.\nOur team will verify your profile shortly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: context.rsp(13),
                              color: Colors.grey.shade600,
                              height: 1.5),
                        ),

                        const SizedBox(height: 22),

                        // ── Live status checker card ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00897B)
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isChecking
                                        ? const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF00897B),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.radar_rounded,
                                            color: Color(0xFF00897B),
                                            size: 18,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isChecking
                                              ? 'Checking verification status...'
                                              : 'Auto-checking status',
                                          style: TextStyle(
                                              fontSize: context.rsp(13),
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  const Color(0xFF1F2937)),
                                        ),
                                        Text(
                                          _isChecking
                                              ? 'Contacting LocalServe servers'
                                              : 'Next check in $_secondsUntilNextCheck sec',
                                          style: TextStyle(
                                              fontSize: context.rsp(11),
                                              color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Manual refresh button
                                  GestureDetector(
                                    onTap: _isChecking
                                        ? null
                                        : () => _checkVerificationStatus(
                                            manual: true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: _isChecking
                                            ? Colors.grey.shade100
                                            : const Color(0xFF00897B),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            size: 14,
                                            color: _isChecking
                                                ? Colors.grey.shade400
                                                : Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Check Now',
                                            style: TextStyle(
                                              fontSize: context.rsp(11),
                                              fontWeight: FontWeight.bold,
                                              color: _isChecking
                                                  ? Colors.grey.shade400
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Progress bar showing countdown
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _isChecking
                                      ? null
                                      : (30 - _secondsUntilNextCheck) / 30,
                                  backgroundColor: Colors.grey.shade100,
                                  color: const Color(0xFF00897B),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Checklist card ──
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.sw * 0.048),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Verification Checklist',
                                  style: TextStyle(
                                      fontSize: context.rsp(14),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937))),
                              const SizedBox(height: 14),
                              _step(context, 1,
                                  'Basic Profile & Contact Details',
                                  'Name, phone, email registered', true),
                              _divider(),
                              _step(context, 2, 'Trade & Rate Card',
                                  'Profession, experience & hourly rate',
                                  true),
                              _divider(),
                              _step(context, 3,
                                  'Government ID Uploaded',
                                  'Aadhaar / PAN submitted', true),
                              _divider(),
                              _step(context, 4,
                                  'Admin Background Check',
                                  'Police clearance verification', false),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Time estimate card ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF00897B)
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00897B)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Color(0xFF00897B),
                                    size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This screen auto-checks every 30 seconds. Once verified, you\'ll be taken to your dashboard automatically.',
                                  style: TextStyle(
                                      fontSize: context.rsp(12),
                                      color: const Color(0xFF00695C),
                                      height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Return to Login button ──
                        SizedBox(
                          width: double.infinity,
                          height: context.rpx(50),
                          child: ElevatedButton(
                            onPressed: () {
                              authService.logout();
                              Navigator.pushReplacementNamed(
                                  context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text('Return to Login',
                                    style: TextStyle(
                                        fontSize: context.rsp(15),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(BuildContext context, int num, String title, String subtitle,
      bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done
                  ? Colors.green.shade500
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 15)
                  : Text('$num',
                      style: TextStyle(
                          fontSize: context.rsp(11),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: context.rsp(13),
                        fontWeight: FontWeight.w600,
                        color: done
                            ? const Color(0xFF1F2937)
                            : Colors.grey.shade400)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: context.rsp(11),
                        color: done
                            ? Colors.grey.shade500
                            : Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
        child: Container(
          width: 1,
          height: 14,
          color: Colors.grey.shade200,
        ),
      );
}
