import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_client.dart';
import '../../core/utils/responsive.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _expController = TextEditingController(text: '1');

  // Categories fetched from admin backend
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;
  String? _selectedCategoryId;

  // Areas fetched from backend
  List<Map<String, dynamic>> _areas = [];
  bool _loadingAreas = true;
  String? _selectedArea;
  String _selectedProfession = '';
  double _selectedRate = 0;

  bool _isLoading = false;
  bool _obscurePassword = true;

  File? _aadhaarFile;
  File? _panFile;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _expController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final response = await ApiClient().get('/areas');
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final list = (data['areas'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _areas = list;
        _loadingAreas = false;
        if (list.isNotEmpty) {
          _selectedArea = list[0]['name']?.toString();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _areas = [
          {'id': '1', 'name': 'Anna Nagar'},
          {'id': '2', 'name': 'KK Nagar'},
          {'id': '3', 'name': 'Kalavasal'},
          {'id': '4', 'name': 'Mattuthavani'},
          {'id': '5', 'name': 'Tallakulam'},
          {'id': '6', 'name': 'Arapalayam'},
          {'id': '7', 'name': 'Bypass Road'},
        ];
        _loadingAreas = false;
        _selectedArea = 'Anna Nagar';
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiClient().get('/categories');
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final list = (data['categories'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _categories = list;
        _loadingCategories = false;
        if (list.isNotEmpty) {
          _selectedCategoryId = list[0]['_id']?.toString();
          _selectedProfession = list[0]['name']?.toString() ?? '';
          _selectedRate =
              (list[0]['startingPrice'] as num?)?.toDouble() ?? 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      // Fall back to defaults if API fails
      setState(() {
        _categories = [
          {'_id': '1', 'name': 'Electrician', 'startingPrice': 199},
          {'_id': '2', 'name': 'Plumbing', 'startingPrice': 249},
          {'_id': '3', 'name': 'Home Cleaning', 'startingPrice': 499},
          {'_id': '4', 'name': 'AC Repair', 'startingPrice': 399},
          {'_id': '5', 'name': 'Carpentry', 'startingPrice': 299},
        ];
        _loadingCategories = false;
        _selectedCategoryId = '1';
        _selectedProfession = 'Electrician';
        _selectedRate = 199;
      });
    }
  }

  Future<void> _pickImage(bool isAadhaar) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(isAadhaar ? 'Upload Aadhaar Card' : 'Upload PAN Card',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_outlined,
                    color: Color(0xFF00897B)),
              ),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_outlined,
                    color: Color(0xFF00897B)),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (source == null) return;
    final picked =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      if (isAadhaar) {
        _aadhaarFile = File(picked.path);
      } else {
        _panFile = File(picked.path);
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final success = await authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      profession: _selectedProfession,
      area: _selectedArea ?? 'Madurai',
      experienceYears: int.tryParse(_expController.text.trim()) ?? 1,
      hourlyRate: _selectedRate.toInt(),
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/kyc_pending');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ??
              'Registration failed. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    context.sw * 0.05, 10, context.sw * 0.05, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LocalServe',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.rsp(15),
                                    fontWeight: FontWeight.bold)),
                            Text('Partner Registration',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: context.rsp(11))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Join as a Verified Pro',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rsp(21),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(
                        'Daily bookings · Zero commission on first 10 jobs',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: context.rsp(11))),
                  ],
                ),
              ),

              // ── Form body ──
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                          context.sw * 0.044, 18,
                          context.sw * 0.044, 24),
                      children: [
                        // ── Card 1: Personal Info ──
                        _card(
                          step: 1,
                          title: 'Personal Info',
                          subtitle: 'Basic contact details',
                          children: [
                            _field(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'e.g. Suresh Kumar',
                              icon: Icons.person_outline,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Name required'
                                  : null,
                            ),
                            const SizedBox(height: 11),
                            _field(
                              controller: _phoneController,
                              label: 'Mobile Number',
                              hint: '+91 98401 23456',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.length < 10
                                  ? 'Valid 10-digit number required'
                                  : null,
                            ),
                            const SizedBox(height: 11),
                            _field(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'suresh.pro@gmail.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v == null || !v.contains('@')
                                      ? 'Valid email required'
                                      : null,
                            ),
                            const SizedBox(height: 11),
                            _field(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Minimum 6 characters',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) => v == null || v.length < 6
                                  ? 'Minimum 6 characters'
                                  : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Card 2: Trade & Experience ──
                        _card(
                          step: 2,
                          title: 'Trade & Experience',
                          subtitle: 'Your skill and pricing',
                          children: [
                            Text('Primary Trade / Skill',
                                style: TextStyle(
                                    fontSize: context.rsp(12),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600)),
                            const SizedBox(height: 6),
                            // ── Profession dropdown from admin categories ──
                            _loadingCategories
                                ? Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F8F7),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F8F7),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _selectedCategoryId,
                                        icon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey.shade500),
                                        style: TextStyle(
                                            fontSize: context.rsp(14),
                                            color:
                                                const Color(0xFF1F2937)),
                                        items: _categories.map((cat) {
                                          return DropdownMenuItem<String>(
                                            value: cat['_id']?.toString(),
                                            child: Text(
                                                cat['name']?.toString() ??
                                                    ''),
                                          );
                                        }).toList(),
                                        onChanged: (id) {
                                          final cat = _categories
                                              .firstWhere((c) =>
                                                  c['_id']?.toString() ==
                                                  id);
                                          setState(() {
                                            _selectedCategoryId = id;
                                            _selectedProfession =
                                                cat['name']?.toString() ??
                                                    '';
                                            _selectedRate =
                                                (cat['startingPrice']
                                                            as num?)
                                                        ?.toDouble() ??
                                                    0;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 11),

                            // ── Admin-fixed rate display (read-only) ──
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B)
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF00897B)
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.currency_rupee,
                                      size: 18,
                                      color: Color(0xFF00897B)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Platform Rate (Admin Fixed)',
                                          style: TextStyle(
                                              fontSize: context.rsp(11),
                                              color: Colors.grey.shade500),
                                        ),
                                        Text(
                                          _selectedRate > 0
                                              ? '₹${_selectedRate.toInt()} / hour'
                                              : 'Select trade above',
                                          style: TextStyle(
                                              fontSize: context.rsp(14),
                                              fontWeight: FontWeight.bold,
                                              color: const Color(
                                                  0xFF1F2937)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00897B)
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_outline,
                                            size: 11,
                                            color: Color(0xFF00897B)),
                                        const SizedBox(width: 3),
                                        Text('Fixed',
                                            style: TextStyle(
                                                fontSize: context.rsp(10),
                                                fontWeight: FontWeight.bold,
                                                color: const Color(
                                                    0xFF00897B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 11),
                            Text('Working Area / Locality',
                                style: TextStyle(
                                    fontSize: context.rsp(12),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600)),
                            const SizedBox(height: 6),
                            _loadingAreas
                                ? Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F8F7),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F8F7),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 20,
                                            color: Colors.grey.shade400),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: _selectedArea,
                                              icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color:
                                                      Colors.grey.shade500),
                                              style: TextStyle(
                                                  fontSize: context.rsp(14),
                                                  color: const Color(
                                                      0xFF1F2937)),
                                              items: _areas.map((area) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: area['name']
                                                      ?.toString(),
                                                  child: Text(
                                                      area['name']
                                                              ?.toString() ??
                                                          ''),
                                                );
                                              }).toList(),
                                              onChanged: (name) {
                                                setState(() =>
                                                    _selectedArea = name);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Card 3: Identity Proof ──
                        _card(
                          step: 3,
                          title: 'Identity Proof',
                          subtitle: 'For partner verification',
                          children: [
                            _uploadTile(
                              isAadhaar: true,
                              icon: Icons.badge_outlined,
                              title: 'Aadhaar Card',
                              subtitle: 'Front & back photo',
                              file: _aadhaarFile,
                            ),
                            const SizedBox(height: 10),
                            _uploadTile(
                              isAadhaar: false,
                              icon: Icons.credit_card_outlined,
                              title: 'PAN Card',
                              subtitle: 'Clear photo of PAN',
                              file: _panFile,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Submit button ──
                        SizedBox(
                          width: double.infinity,
                          height: context.rpx(52),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00897B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                          Icons.check_circle_outline,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Submit Partner Application',
                                        style: TextStyle(
                                            fontSize: context.rsp(15),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text('Already registered? ',
                                  style: TextStyle(
                                      fontSize: context.rsp(13),
                                      color: Colors.grey.shade600)),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text('Sign In',
                                    style: TextStyle(
                                        fontSize: context.rsp(13),
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF00897B))),
                              ),
                            ],
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

  Widget _card({
    required int step,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
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
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                    color: Color(0xFF00897B), shape: BoxShape.circle),
                child: Center(
                  child: Text('$step',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rsp(13),
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: context.rsp(14),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937))),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: context.rsp(11),
                          color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _uploadTile({
    required bool isAadhaar,
    required IconData icon,
    required String title,
    required String subtitle,
    File? file,
  }) {
    final uploaded = file != null;
    return GestureDetector(
      onTap: () => _pickImage(isAadhaar),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: uploaded
              ? const Color(0xFF00897B).withValues(alpha: 0.06)
              : const Color(0xFFF6F8F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF00897B).withValues(alpha: 0.5)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            // Preview or icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: uploaded
                  ? Image.file(file,
                      width: 44, height: 44, fit: BoxFit.cover)
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon,
                          color: const Color(0xFF00897B), size: 22),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: context.rsp(13),
                          color: const Color(0xFF1F2937))),
                  Text(
                    uploaded ? 'Tap to change photo' : subtitle,
                    style: TextStyle(
                        fontSize: context.rsp(11),
                        color: uploaded
                            ? const Color(0xFF00897B)
                            : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: uploaded
                    ? Colors.green.shade600
                    : const Color(0xFF00897B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      uploaded
                          ? Icons.check_rounded
                          : Icons.upload_rounded,
                      color: Colors.white,
                      size: 13),
                  const SizedBox(width: 3),
                  Text(uploaded ? 'Done' : 'Upload',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rsp(11),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
          fontSize: context.rsp(14), color: const Color(0xFF1F2937)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF6F8F7),
        labelStyle: TextStyle(
            fontSize: context.rsp(12), color: Colors.grey.shade500),
        hintStyle: TextStyle(
            fontSize: context.rsp(13), color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF00897B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
