import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/local_storage_service.dart';
import '../../main.dart';
import 'farmer_search_screen.dart';
import 'add_dose_screen.dart';
import 'analytics_screen.dart';
import 'admin_status_screen.dart'; // Add this import

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Exit confirmation handler
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on dashboard tab, go to dashboard tab first
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Don't exit app
    } else {
      // If on dashboard tab, show exit confirmation
      return await _showExitDialog() ?? false;
    }
  }

  Future<bool?> _showExitDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.exit_to_app, color: Color(0xFFFF6F00)),
            const SizedBox(width: 12),
            Text(
              'अॅप बंद करा?',
              style: GoogleFonts.notoSansDevanagari(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'तुम्हाला नक्की अॅप बंद करायचे आहे का?',
          style: GoogleFonts.notoSansDevanagari(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'नाही',
              style: GoogleFonts.notoSansDevanagari(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'होय, बंद करा',
              style: GoogleFonts.notoSansDevanagari(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Updated screens list to include AdminStatusScreen
    final screens = [
      _buildDashboardContent(),
      const FarmerSearchScreen(),
      const AnalyticsScreen(),
      const AdminStatusScreen(), // New Status Management tab
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              // SKP Logo Image
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF6F00), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/skp_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'SKP',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'प्रशासक पॅनेल',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6F00),
                    ),
                  ),
                  Text(
                    'Admin Panel',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFFFF6F00)),
              onPressed: () {
                // TODO: Implement notifications screen
                _showComingSoonSnackbar();
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFFFF6F00)),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'बाहेर पडा',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFFFF6F00),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.notoSansDevanagari(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansDevanagari(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 28),
              label: 'डॅशबोर्ड',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people, size: 28),
              label: 'शेतकरी',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics, size: 28),
              label: 'अहवाल',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.circle_notifications, size: 28),
              label: 'स्टेटस',
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDoseScreen()),
                  );
                },
                backgroundColor: const Color(0xFFFF6F00),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'डोस जोडा',
                  style: GoogleFonts.notoSansDevanagari(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildDashboardContent() {
    final storageService = Provider.of<LocalStorageService>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: storageService.getAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
            ),
          );
        }

        final analytics = snapshot.data ?? {};

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6F00).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'स्वागत आहे! 🙏',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome to Admin Dashboard',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'आज: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: Colors.white24,
                      ),
                    ],
                  ),
                ),

                // Stats Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        icon: Icons.people,
                        titleMarathi: 'एकूण शेतकरी',
                        titleEnglish: 'Total Farmers',
                        value: '${analytics['totalFarmers'] ?? 0}',
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        icon: Icons.water_drop,
                        titleMarathi: 'एकूण डोस',
                        titleEnglish: 'Total Doses',
                        value: '${analytics['totalDoses'] ?? 0}',
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        icon: Icons.credit_card,
                        titleMarathi: 'उधारी',
                        titleEnglish: 'Credit',
                        value: '₹${(analytics['totalCredit'] ?? 0).toStringAsFixed(0)}',
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        icon: Icons.payments,
                        titleMarathi: 'रोख',
                        titleEnglish: 'Cash',
                        value: '₹${(analytics['totalCash'] ?? 0).toStringAsFixed(0)}',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'त्वरित क्रिया',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Quick Actions Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildActionCard(
                        icon: Icons.person_search,
                        iconColor: Colors.blue,
                        titleMarathi: 'शेतकरी शोधा',
                        titleEnglish: 'Search Farmers',
                        subtitleMarathi: 'शेतकरी माहिती पहा आणि व्यवस्थापित करा',
                        subtitleEnglish: 'View and manage farmer information',
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.add_circle,
                        iconColor: Colors.green,
                        titleMarathi: 'नवीन डोस जोडा',
                        titleEnglish: 'Add New Dose',
                        subtitleMarathi: 'खत डोस नोंद करा',
                        subtitleEnglish: 'Record fertilizer application',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddDoseScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.analytics,
                        iconColor: Colors.purple,
                        titleMarathi: 'अहवाल पहा',
                        titleEnglish: 'View Reports',
                        subtitleMarathi: 'तपशीलवार अहवाल आणि विश्लेषण',
                        subtitleEnglish: 'Detailed reports and analytics',
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.circle_notifications,
                        iconColor: Colors.orange,
                        titleMarathi: 'स्टेटस व्यवस्थापन',
                        titleEnglish: 'Status Management',
                        subtitleMarathi: 'शेतकऱ्यांसाठी अपडेट्स आणि सूचना व्यवस्थापित करा',
                        subtitleEnglish: 'Manage updates and notifications for farmers',
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String titleMarathi,
    required String titleEnglish,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titleMarathi,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            titleEnglish,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleMarathi,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      titleEnglish,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleMarathi,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      subtitleEnglish,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'लवकरच उपलब्ध होईल',
          style: GoogleFonts.notoSansDevanagari(),
        ),
        backgroundColor: const Color(0xFFFF6F00),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'बाहेर पडा',
              style: GoogleFonts.notoSansDevanagari(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'तुम्हाला नक्की बाहेर पडायचे आहे का?',
          style: GoogleFonts.notoSansDevanagari(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'रद्द करा',
              style: GoogleFonts.notoSansDevanagari(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'बाहेर पडा',
              style: GoogleFonts.notoSansDevanagari(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (route) => false,
        );
      }
    }
  }
}