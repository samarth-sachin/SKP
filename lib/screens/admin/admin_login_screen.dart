import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ✅ 5 ADMIN ACCOUNTS (Your credentials + 3 additional)
  final Map<String, Map<String, String>> _adminAccounts = {
    'sai': {
      'password': 'sachin',
      'name': 'साई', // Sai
      'nameEn': 'Sai',
      'role': 'मुख्य व्यवस्थापक', // Main Admin
      'roleEn': 'Owner',
    },
    'sam': {
      'password': 'Sam@0106',
      'name': 'सॅम', // Sam
      'nameEn': 'Sam',
      'role': 'व्यवस्थापक', // Manager
      'roleEn': 'Manager',
    },
    'admin': {
      'password': 'admin@123',
      'name': 'प्रशासक', // Admin
      'nameEn': 'Admin',
      'role': 'दुकान व्यवस्थापक', // Shop Manager
      'roleEn': 'Shop Manager',
    },
    'staff1': {
      'password': 'staff@123',
      'name': 'कर्मचारी 1', // Staff 1
      'nameEn': 'Staff 1',
      'role': 'दुकान सहाय्यक', // Shop Assistant
      'roleEn': 'Assistant',
    },
    'staff2': {
      'password': 'staff@456',
      'name': 'कर्मचारी 2', // Staff 2
      'nameEn': 'Staff 2',
      'role': 'दुकान सहाय्यक', // Shop Assistant
      'roleEn': 'Assistant',
    },
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    // ✅ Check if credentials match
    if (_adminAccounts.containsKey(username) &&
        _adminAccounts[username]!['password'] == password) {
      // ✅ Successful login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', true);
      await prefs.setString('adminUsername', username);
      await prefs.setString('adminName', _adminAccounts[username]!['name']!);
      await prefs.setString('adminNameEn', _adminAccounts[username]!['nameEn']!);
      await prefs.setString('adminRole', _adminAccounts[username]!['role']!);
      await prefs.setString('adminRoleEn', _adminAccounts[username]!['roleEn']!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'स्वागत आहे!',
                      style: GoogleFonts.notoSansDevanagari(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _adminAccounts[username]!['name']!,
                      style: GoogleFonts.notoSansDevanagari(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      // ❌ Invalid credentials
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '❌ चुकीचे युजरनेम किंवा पासवर्ड!',
                  style: GoogleFonts.notoSansDevanagari(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Shake animation for wrong password
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[800],
        title: Text(
          'प्रशासक लॉगिन',
          style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Admin Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[700]!, Colors.orange[900]!],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // Welcome Text
              Text(
                'स्वागत आहे',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Admin Panel',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'युजरनेम / Username',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  prefixIcon: Icon(Icons.person, color: Colors.orange[800]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'कृपया युजरनेम प्रविष्ट करा';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'पासवर्ड / Password',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  prefixIcon: Icon(Icons.lock, color: Colors.orange[800]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'कृपया पासवर्ड प्रविष्ट करा';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login),
                      const SizedBox(width: 12),
                      Text(
                        'लॉगिन करा',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Info Card - Admin Accounts (FOR DEVELOPMENT - REMOVE IN PRODUCTION)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'अॅडमिन खाती',
                          style: GoogleFonts.notoSansDevanagari(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._adminAccounts.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.key} - ${entry.value['nameEn']} (${entry.value['roleEn']})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
