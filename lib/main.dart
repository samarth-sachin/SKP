import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'screens/farmer/farmer_home_screen.dart';
import 'screens/farmer/farmer_registration_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SKPSmartFarmApp());
}

class SKPSmartFarmApp extends StatelessWidget {
  const SKPSmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocalStorageService(),
      child: MaterialApp(
        title: 'SKP SmartFarm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2E7D32),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFFA5D6A7),
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF2E7D32),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// Enhanced Splash Screen with Beautiful Green Background
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.elasticOut)),
    );
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4));
    
    final prefs = await SharedPreferences.getInstance();
    final isRegistered = prefs.getBool('isRegistered') ?? false;
    final isAdmin = prefs.getBool('isAdmin') ?? false;

    if (!mounted) return;

    if (isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else if (isRegistered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20), // Dark green
              Color(0xFF2E7D32), // Medium green
              Color(0xFF388E3C), // Light green
            ],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced Farming field pattern overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: CustomPaint(
                  painter: FarmingFieldPainter(),
                ),
              ),
            ),
            
            // Animated floating particles
            Positioned.fill(
              child: CustomPaint(
                painter: FloatingParticlesPainter(),
              ),
            ),

            // Main Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Animated Logo Container
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 5,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: const Color(0xFF1B5E20).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 10,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Image.asset(
                              'assets/images/skp_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.agriculture,
                                        size: 70,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'SKP',
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 4,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Enhanced Animated Welcome Text
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: Column(
                          children: [
                            Text(
                              'सुस्वागतम्',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(0, 4),
                                    blurRadius: 15,
                                  ),
                                  Shadow(
                                    color: const Color(0xFF1B5E20).withOpacity(0.4),
                                    offset: const Offset(0, 0),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Welcome',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 100),
                      
                      // Loading Indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Version Text
                      Text(
                        ' ',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Enhanced Farming Field Painter
class FarmingFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw enhanced grass/crop patterns
    for (int i = 0; i < 80; i++) {
      final x = (i * 20.0) % size.width;
      final y = size.height - (i * 30.0) % size.height;
      
      // Draw grass blades with variation
      final path = Path();
      path.moveTo(x, y);
      path.quadraticBezierTo(x + 2 + (i % 3), y - 12 - (i % 8), x + 5 + (i % 2), y);
      path.moveTo(x + 2, y);
      path.quadraticBezierTo(x + 5, y - 10 - (i % 6), x + 8, y);
      canvas.drawPath(path, paint);
    }
    
    // Draw crop rows pattern with curves
    for (int i = 0; i < 12; i++) {
      final y = size.height * 0.5 + (i * 35);
      final path = Path();
      path.moveTo(0, y);
      for (int j = 0; j < size.width; j += 40) {
        path.quadraticBezierTo(
          j + 20, 
          y + 10 * (j % 3 == 0 ? 1 : -1), 
          j + 40, 
          y
        );
      }
      canvas.drawPath(path, strokePaint);
    }

    // Draw sun/moon in corner
    final sunPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 40, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating Particles Painter for background animation
class FloatingParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 15; i++) {
      final x = (DateTime.now().millisecondsSinceEpoch / 50 + i * 100) % size.width;
      final y = (DateTime.now().millisecondsSinceEpoch / 80 + i * 80) % size.height;
      final radius = 1 + (i % 3).toDouble();
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced Role Selection Screen with Green Background
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(  // ✅ Make it scrollable
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                // Top Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Logo
                      Container(
                        width: 100,  // ✅ Reduced size for large fonts
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/skp_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.agriculture, size: 40, color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // App name - Fixed font size
                      Text(
                        'SKP बळीराजा',
                        textScaleFactor: 1.0,  // ✅ Ignore system font scaling
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'शेतकऱ्यांसाठी खत व्यवस्थापन',
                        textScaleFactor: 1.0,  // ✅ Ignore system font scaling
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Role Selection - Flexible space
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'तुम्ही कोण आहात?',
                        textScaleFactor: 1.0,  // ✅ Fixed font size
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Who are you?',
                        textScaleFactor: 1.0,  // ✅ Fixed font size
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Farmer Card
                      _buildRoleCard(
                        context,
                        icon: Icons.person,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        ),
                        titleMarathi: 'शेतकरी',
                        titleEnglish: 'Farmer',
                        subtitleMarathi: 'खत माहिती आणि सूचना मिळवा',
                        subtitleEnglish: 'Get fertilizer info & notifications',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FarmerRegistrationScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Admin Card
                      _buildRoleCard(
                        context,
                        icon: Icons.admin_panel_settings,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                        ),
                        titleMarathi: 'दुकानदार / प्रशासक',
                        titleEnglish: 'Shop Owner / Admin',
                        subtitleMarathi: 'शेतकरी आणि खत व्यवस्थापन',
                        subtitleEnglish: 'Manage farmers & fertilizers',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminLoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    ' ',
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,  // ✅ Fixed font size
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 10,
                      color: Colors.grey[600],
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

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required Gradient gradient,
    required String titleMarathi,
    required String titleEnglish,
    required String subtitleMarathi,
    required String subtitleEnglish,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),  // ✅ Reduced padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),  // ✅ Reduced padding
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: Colors.white),  // ✅ Reduced icon size
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleMarathi,
                      textScaleFactor: 1.0,  // ✅ Fixed font size
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      titleEnglish,
                      textScaleFactor: 1.0,  // ✅ Fixed font size
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleMarathi,
                      textScaleFactor: 1.0,  // ✅ Fixed font size
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
