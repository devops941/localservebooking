import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import 'provider_kyc_pending_screen.dart';

class ProviderRegisterScreen extends StatefulWidget {
  const ProviderRegisterScreen({super.key});

  @override
  State<ProviderRegisterScreen> createState() => _ProviderRegisterScreenState();
}

class _ProviderRegisterScreenState extends State<ProviderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rateController = TextEditingController(text: '249');
  final _expController = TextEditingController(text: '4');
  final _areaController = TextEditingController(text: 'Adyar, Chennai');

  String _selectedProfession = 'Electrician';
  bool _docUploaded = true;
  bool _isLoading = false;

  final List<String> _professions = [
    'Electrician',
    'Plumber',
    'AC Repair & Technician',
    'Home Cleaning Specialist',
    'Carpentry & Woodwork',
    'Painter & Waterproofing',
    'Appliance Repair Tech',
    'Pest Control Operator',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rateController.dispose();
    _expController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await AuthService().registerProvider(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      profession: _selectedProfession,
      area: _areaController.text.trim(),
      hourlyRate: double.tryParse(_rateController.text) ?? 249,
      experienceYears: int.tryParse(_expController.text) ?? 3,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderKycPendingScreen(
            providerName: _nameController.text.trim(),
            profession: _selectedProfession,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SERVICE PARTNER REGISTRATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Join as a Verified Pro 🛠️',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Receive local daily job bookings directly on your phone with zero commission on your first 10 jobs.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 24),

                // Personal Info
                const Text('1. Personal Contact Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'e.g. Suresh Kumar',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Primary Mobile Number',
                  hintText: 'e.g. +91 98401 23456',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 10 ? 'Valid 10-digit phone required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'e.g. suresh.pro@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !v!.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => v!.length < 6 ? 'Minimum 6 chars' : null,
                ),

                const SizedBox(height: 24),
                // Trade & Skill Info
                const Text('2. Trade & Experience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 12),
                const Text('Primary Trade / Skill', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedProfession,
                      items: _professions.map((prof) {
                        return DropdownMenuItem(value: prof, child: Text(prof));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedProfession = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _expController,
                        labelText: 'Experience (Years)',
                        hintText: 'e.g. 5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _rateController,
                        labelText: 'Starting Rate (₹)',
                        hintText: 'e.g. 249',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _areaController,
                  labelText: 'Primary Working Locality / Area',
                  hintText: 'e.g. Adyar, Chennai',
                  prefixIcon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 24),
                // Document Proofs
                const Text('3. Government ID / Trade License', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present_rounded, color: Colors.teal, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Aadhaar / ID Proof Attached', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('sample_aadhaar_front_back.pdf (Attached)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _docUploaded = !_docUploaded);
                        },
                        child: Text(_docUploaded ? 'Change' : 'Upload', style: const TextStyle(color: Colors.teal)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Submit Partner Application',
                  isLoading: _isLoading,
                  backgroundColor: Colors.teal,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
