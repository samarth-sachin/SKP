import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../services/notification_service.dart';
import '../../models/farmer_model.dart';
import '../../models/land_model.dart';
import '../../models/dose_model.dart';
import '../../main.dart';
import 'weather_screen.dart';
import 'notifications_screen.dart';
import 'land_details_screen.dart';
import 'fertilizer_info_screen.dart';
import 'add_land_screen.dart';
import 'status_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _selectedIndex = 0;
  String _farmerId = '';
  String _farmerName = '';
  FarmerModel? _currentFarmer;
  DateTime? _nextDoseDate;
  int _unreadNotifications = 0;

  // Exit confirmation handler
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    } else {
      return await _showExitDialog() ?? false;
    }
  }

  Future<bool?> _showExitDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.exit_to_app, color: Color(0xFF2E7D32)),
            const SizedBox(width: 12),
            Text(
              'अॅप बंद करा?',
              style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
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
            child: Text('नाही', style: GoogleFonts.notoSansDevanagari(color: Colors.grey[700], fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('होय, बंद करा', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
    _calculateNextDose();
  }

  // ✅ Load farmer data from SharedPreferences & Firebase
  Future<void> _loadFarmerData() async {
    final prefs = await SharedPreferences.getInstance();
    final farmerId = prefs.getString('farmerId') ?? '';

    if (farmerId.isNotEmpty) {
      final farmer = await FirebaseService.getFarmerById(farmerId);
      setState(() {
        _farmerId = farmerId;
        _currentFarmer = farmer;
        _farmerName = farmer?.name ?? 'शेतकरी';
      });
    }
  }

  // ✅ Calculate next dose date from all lands
  Future<void> _calculateNextDose() async {
    if (_farmerId.isEmpty) return;

    try {
      final lands = await FirebaseService.getLandsByFarmerId(_farmerId).first;
      DateTime? nearest;

      for (var land in lands) {
        final doses = await FirebaseService.getDosesForLand(land.id).first;
        if (doses.isNotEmpty) {
          final latestDose = doses.first;
          if (latestDose.nextDoseDate != null) {
            if (nearest == null || latestDose.nextDoseDate!.isBefore(nearest)) {
              nearest = latestDose.nextDoseDate;
            }
          }
        }
      }

      if (mounted) {
        setState(() => _nextDoseDate = nearest);
      }
    } catch (e) {
      print('Error calculating next dose: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      const StatusScreen(),
      const WeatherScreen(),
      const NotificationsScreen(),
      _buildProfileContent(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _selectedIndex == 0 ? _buildAppBar() : null,
        body: screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: GoogleFonts.notoSansDevanagari(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.notoSansDevanagari(fontSize: 11),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'मुख्यपृष्ठ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.circle_notifications_rounded),
                label: 'अपडेट्स',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny_rounded),
                label: 'हवामान',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_rounded),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'सूचना',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'प्रोफाइल',
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E7D32), width: 2),
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
                          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
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
                'शेतसखा',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              Text(
                'शेतकरी मित्र',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // ✅ Dynamic notification badge
        StreamBuilder<int>(
          stream: NotificationService.getUnreadCount(_farmerId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _unreadNotifications != count) {
                setState(() => _unreadNotifications = count);
              }
            });

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2E7D32)),
                  onPressed: () => setState(() => _selectedIndex = 3),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
          onPressed: _contactShop,
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    if (_farmerId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadFarmerData();
        await _calculateNextDose();
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Dynamic Welcome Card with Next Dose
            _buildWelcomeCard(),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.call,
                    label: 'संपर्क\nकरा',
                    color: const Color(0xFF1976D2),
                    onTap: _contactShop,
                  ),
                  _buildQuickActionCard(
                    icon: Icons.cloud,
                    label: 'हवामान\nमाहिती',
                    color: const Color(0xFF0288D1),
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _buildQuickActionCard(
                    icon: Icons.info_outline,
                    label: 'खत\nमाहिती',
                    color: const Color(0xFF388E3C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FertilizerInfoScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // My Lands Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'माझ्या जमिनी',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddLandScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text('नवीन जोडा', style: GoogleFonts.notoSansDevanagari(fontSize: 13)),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),

            // ✅ Lands List from Firebase
            _buildLandsList(),

            const SizedBox(height: 20),
            _buildFertilizerInfoSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ✅ Dynamic Welcome Card
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'नमस्कार, $_farmerName',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateTime.now().hour < 12
                          ? 'शुभ सकाळ! आजचा दिवस चांगला जावो'
                          : DateTime.now().hour < 17
                          ? 'शुभ दुपार!'
                          : 'शुभ संध्याकाळ!',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ Dynamic Next Dose Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _nextDoseDate != null
                        ? 'पुढील खत डोस: ${_getDaysUntil(_nextDoseDate!)}'
                        : 'पुढील खत डोसची माहिती उपलब्ध नाही',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Calculate days until next dose
  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'आज देणे आवश्यक!';
    } else if (difference == 0) {
      return 'आज';
    } else if (difference == 1) {
      return 'उद्या';
    } else {
      return '$difference दिवसांनी';
    }
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rest of the methods remain the same...
  // (Continue with _buildLandsList, _buildLandCard, etc. - they're already good)

  Widget _buildLandsList() {
    return StreamBuilder<List<LandModel>>(
      stream: FirebaseService.getLandsByFarmerId(_farmerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyLands();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final land = snapshot.data![index];
            return _buildLandCard(land);
          },
        );
      },
    );
  }

  Widget _buildLandCard(LandModel land) {
    return StreamBuilder<List<DoseModel>>(
      stream: FirebaseService.getDosesForLand(land.id),
      builder: (context, doseSnapshot) {
        final doses = doseSnapshot.data ?? [];
        final latestDose = doses.isNotEmpty ? doses.first : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LandDetailsScreen(land: land)),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.landscape, color: Color(0xFF2E7D32), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                land.landName,
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                land.location,
                                style: GoogleFonts.notoSansDevanagari(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFF2E7D32), size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLandInfo(
                            icon: Icons.grass,
                            label: 'पीक',
                            value: land.currentCrop,
                          ),
                        ),
                        Expanded(
                          child: _buildLandInfo(
                            icon: Icons.straighten,
                            label: 'क्षेत्र',
                            value: '${land.areaInAcres} एकर',
                          ),
                        ),
                      ],
                    ),
                    if (latestDose != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: latestDose.paymentType == 'Credit'
                              ? Colors.orange[50]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              latestDose.paymentType == 'Credit'
                                  ? Icons.pending_actions
                                  : Icons.check_circle,
                              size: 18,
                              color: latestDose.paymentType == 'Credit'
                                  ? Colors.orange[700]
                                  : Colors.green[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                latestDose.nextDoseDate != null
                                    ? 'पुढील डोस: ${_formatDate(latestDose.nextDoseDate!)}'
                                    : 'शेवटचा डोस: ${_formatDate(latestDose.applicationDate)}',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: latestDose.paymentType == 'Credit'
                                      ? Colors.orange[800]
                                      : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.notoSansDevanagari(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyLands() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.landscape_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'अद्याप जमीन जोडलेली नाही',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'आपली जमीन जोडण्यासाठी वर क्लिक करा',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansDevanagari(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.blue[100]!]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'खत माहिती',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'युरिया खताचा वापर पिकांच्या वाढीसाठी केला जातो. हे नायट्रोजनचा उत्तम स्रोत आहे.',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 13,
              color: Colors.blue[900],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FertilizerInfoScreen()),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text('अधिक वाचा', style: GoogleFonts.notoSansDevanagari(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_currentFarmer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  child: Text(
                    _currentFarmer!.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentFarmer!.name,
                  style: GoogleFonts.notoSansDevanagari(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'शेतकरी खाते',
                  style: GoogleFonts.notoSansDevanagari(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Profile Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'प्रोफाइल माहिती',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileInfoRow(Icons.location_on, 'गाव', _currentFarmer!.village),
                _buildProfileInfoRow(Icons.phone, 'मोबाईल', _currentFarmer!.phoneNumber),
                if (_currentFarmer!.alternatePhone != null)
                  _buildProfileInfoRow(Icons.phone_android, 'पर्यायी नंबर', _currentFarmer!.alternatePhone!),
                _buildProfileInfoRow(Icons.credit_card, 'आधार', _currentFarmer!.aadhaarNumber),
                _buildProfileInfoRow(
                  Icons.calendar_today,
                  'नोंदणी तारीख',
                  _formatDate(_currentFarmer!.registrationDate),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text('बाहेर पडा', style: GoogleFonts.notoSansDevanagari(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.notoSansDevanagari(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactShop() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '9421112979');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('फोन कॉल करू शकत नाही', style: GoogleFonts.notoSansDevanagari()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('बाहेर पडा', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold)),
        content: Text('तुम्हाला नक्की बाहेर पडायचे आहे का?', style: GoogleFonts.notoSansDevanagari()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('रद्द करा', style: GoogleFonts.notoSansDevanagari()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('बाहेर पडा', style: GoogleFonts.notoSansDevanagari()),
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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
