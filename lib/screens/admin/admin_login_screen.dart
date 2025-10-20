import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showInfoCard = false;

  // ✅ 5 ADMIN ACCOUNTS
  final Map<String, Map<String, String>> _adminAccounts = {
    'sai': {
      'password': 'sachin',
      'name': 'साई',
      'nameEn': 'Sai',
      'role': 'मुख्य व्यवस्थापक',
      'roleEn': 'Owner',
    },
    'sam': {
      'password': 'Sam@0106',
      'name': 'सॅम',
      'nameEn': 'Sam',
      'role': 'व्यवस्थापक',
      'roleEn': 'Manager',
    },
    'admin': {
      'password': 'admin@123',
      'name': 'प्रशासक',
      'nameEn': 'Admin',
      'role': 'दुकान व्यवस्थापक',
      'roleEn': 'Shop Manager',
    },
    'staff1': {
      'password': 'staff@123',
      'name': 'कर्मचारी 1',
      'nameEn': 'Staff 1',
      'role': 'दुकान सहाय्यक',
      'roleEn': 'Assistant',
    },
    'staff2': {
      'password': 'staff@456',
      'name': 'कर्मचारी 2',
      'nameEn': 'Staff 2',
      'role': 'दुकान सहाय्यक',
      'roleEn': 'Assistant',
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

    if (_adminAccounts.containsKey(username) &&
        _adminAccounts[username]!['password'] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', true);
      await prefs.setString('adminUsername', username);
      await prefs.setString('adminName', _adminAccounts[username]!['name']!);
      await prefs.setString('adminNameEn', _adminAccounts[username]!['nameEn']!);
      await prefs.setString('adminRole', _adminAccounts[username]!['role']!);
      await prefs.setString('adminRoleEn', _adminAccounts[username]!['roleEn']!);

      if (!mounted) return;

      // Show success animation
      _showLoginSuccess(username);
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;

      _showLoginError();
      _passwordController.clear();
    }
  }

  void _showLoginSuccess(String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'लॉगिन यशस्वी! 🎉',
                      style: GoogleFonts.notoSansDevanagari(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'स्वागत आहे, ${_adminAccounts[username]!['name']!}',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AdminDashboardScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _showLoginError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF44336),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error, color: Colors.red[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '❌ चुकीचे युजरनेम किंवा पासवर्ड!',
                  style: GoogleFonts.notoSansDevanagari(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7E0), // Light orange background
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: CustomScrollView(
                slivers: [
                  // Beautiful App Bar with Gradient
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'प्रशासक लॉगिन',
                        style: GoogleFonts.notoSansDevanagari(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      centerTitle: true,
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange[800]!,
                              Colors.orange[700]!,
                              Colors.orange[600]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative elements
                            Positioned(
                              top: 20,
                              right: 30,
                              child: Icon(
                                Icons.security,
                                size: 60,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 30,
                              child: Icon(
                                Icons.admin_panel_settings,
                                size: 50,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Welcome Card with Orange Theme
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange[50]!,
                                  Colors.orange[100]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.orange[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange[700]!,
                                        Colors.orange[900]!,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings_rounded,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'एडमिन पॅनेलमध्ये स्वागत आहे',
                                        style: GoogleFonts.notoSansDevanagari(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Secure Admin Access Portal',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Login Form Container
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.orange[100]!,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Username Field
                                  TextFormField(
                                    controller: _usernameController,
                                    style: GoogleFonts.poppins(),
                                    decoration: InputDecoration(
                                      labelText: 'युजरनेम',
                                      labelStyle: GoogleFonts.notoSansDevanagari(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintText: 'आपले युजरनेम प्रविष्ट करा',
                                      hintStyle: GoogleFonts.notoSansDevanagari(
                                        color: Colors.grey[500],
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.orange[50]!.withOpacity(0.3),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.orange[800]!,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'कृपया युजरनेम प्रविष्ट करा';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: GoogleFonts.poppins(),
                                    decoration: InputDecoration(
                                      labelText: 'पासवर्ड',
                                      labelStyle: GoogleFonts.notoSansDevanagari(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintText: 'आपला पासवर्ड प्रविष्ट करा',
                                      hintStyle: GoogleFonts.notoSansDevanagari(
                                        color: Colors.grey[500],
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.lock_rounded,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: Colors.orange[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.orange[50]!.withOpacity(0.3),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.orange[800]!,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
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
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 5,
                                        shadowColor: Colors.orange.withOpacity(0.4),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                          : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login_rounded, size: 24),
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

                                  const SizedBox(height: 24),

                                  // Info Toggle Button
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showInfoCard = !_showInfoCard;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.orange[200]!,
                                        ),
                                        boxShadow: _showInfoCard
                                            ? [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                            : [],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: Colors.orange[700],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'अॅडमिन खाती माहिती',
                                            style: GoogleFonts.notoSansDevanagari(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[900],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            _showInfoCard
                                                ? Icons.expand_less_rounded
                                                : Icons.expand_more_rounded,
                                            color: Colors.orange[700],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Info Card (Collapsible)
                                  if (_showInfoCard) ...[
                                    const SizedBox(height: 16),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.orange[200]!),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.admin_panel_settings_rounded,
                                                color: Colors.orange[700],
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'उपलब्ध अॅडमिन खाती:',
                                                style: GoogleFonts.notoSansDevanagari(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange[900],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          ..._adminAccounts.entries.map((entry) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.orange[100]!,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange[600],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${entry.key} - ${entry.value['name']!}',
                                                          style:
                                                          GoogleFonts.notoSansDevanagari(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.orange[900],
                                                          ),
                                                        ),
                                                        Text(
                                                          '${entry.value['role']!} • पासवर्ड: ${entry.value['password']!}',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 10,
                                                            color: Colors.orange[700],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Footer
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange[100]!,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '🔒 सुरक्षित प्रशासक प्रवेश',
                                  style: GoogleFonts.notoSansDevanagari(
                                    fontSize: 12,
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Secure Admin Access Portal',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.orange[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}