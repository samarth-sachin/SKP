import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../services/local_storage_service.dart';
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
  String _farmerId = '1';
  String _farmerName = '';

  // Exit confirmation handler
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on home tab, go to home tab first
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Don't exit app
    } else {
      // If on home tab, show exit confirmation
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
            const Icon(Icons.exit_to_app, color: Color(0xFF2E7D32)),
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
              backgroundColor: const Color(0xFF2E7D32),
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
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _farmerName = prefs.getString('farmerName') ?? 'शेतकरी';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Updated screens list to include StatusScreen
    final screens = [
      _buildHomeContent(),
      const StatusScreen(),     // Index 1: Status/Updates
      const WeatherScreen(),    // Index 2: Weather
      const NotificationsScreen(), // Index 3: Notifications
      _buildProfileContent(),   // Index 4: Profile
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
                    'बळीराजा',
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
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2E7D32)),
                  onPressed: () => setState(() => _selectedIndex = 3), // Notifications tab
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '3',
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
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
              onPressed: _contactShop,
            ),
          ],
        ),
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.notoSansDevanagari(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansDevanagari(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'मुख्यपृष्ठ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.circle_notifications, size: 28),
              label: 'अपडेट्स',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny, size: 28),
              label: 'हवामान',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, size: 28),
              label: 'सूचना',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: 'प्रोफाइल',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card with Gradient
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF66BB6A),
                  ],
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
                      const Icon(
                        Icons.wb_sunny,
                        color: Colors.amber,
                        size: 32,
                      ),
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
                              'आज पाऊस होण्याची शक्यता 20%',
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'पुढील खत डोस: 5 दिवसांनी',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions Grid
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
                    label: Text(
                      'नवीन जोडा',
                      style: GoogleFonts.notoSansDevanagari(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            // Lands List
            _buildLandsList(),

            const SizedBox(height: 20),

            // Fertilizer Info Section
            _buildFertilizerInfoSection(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
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

  Widget _buildLandsList() {
    final storageService = Provider.of<LocalStorageService>(context);
    
    return StreamBuilder<List<LandModel>>(
      stream: storageService.getLandsByFarmerId(_farmerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
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
            return _buildLandCard(land, storageService);
          },
        );
      },
    );
  }

  Widget _buildLandCard(LandModel land, LocalStorageService storageService) {
    return FutureBuilder<DoseModel?>(
      future: storageService.getLatestDoseForLand(land.id),
      builder: (context, snapshot) {
        final latestDose = snapshot.data;

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
                  MaterialPageRoute(
                    builder: (_) => LandDetailsScreen(land: land),
                  ),
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
                          child: const Icon(
                            Icons.landscape,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
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
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 13,
                                  color: Colors.grey[600],
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
            Text(
              label,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
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
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 13,
              color: Colors.grey[500],
            ),
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
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
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
            label: Text(
              'अधिक वाचा',
              style: GoogleFonts.notoSansDevanagari(fontSize: 13),
            ),
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
                child: const Icon(Icons.person, size: 50, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 16),
              Text(
                _farmerName,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'शेतकरी खाते',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Edit Profile Form
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
                'प्रोफाइल संपादित करा',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                initialValue: _farmerName,
                decoration: InputDecoration(
                  labelText: 'पूर्ण नाव',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                onChanged: (value) {
                  setState(() {
                    _farmerName = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Phone Number (Read-only)
              TextFormField(
                initialValue: '9421112979', // Replace with actual phone from registration
                decoration: InputDecoration(
                  labelText: 'मोबाईल नंबर',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                readOnly: true,
              ),

              const SizedBox(height: 16),

              // Village
              TextFormField(
                initialValue: 'तुमचे गाव', // Replace with actual data
                decoration: InputDecoration(
                  labelText: 'गाव',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 16),

              // Taluka
              TextFormField(
                initialValue: 'तुमची तालुका', // Replace with actual data
                decoration: InputDecoration(
                  labelText: 'तालुका',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.map),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'जतन करा',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
            label: Text(
              'बाहेर पडा',
              style: GoogleFonts.notoSansDevanagari(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Add this method to update profile
Future<void> _updateProfile() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('farmerName', _farmerName);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'प्रोफाइल यशस्वीरित्या अपडेट केली',
        style: GoogleFonts.notoSansDevanagari(),
      ),
      backgroundColor: Colors.green,
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
            content: Text(
              'फोन कॉल करू शकत नाही',
              style: GoogleFonts.notoSansDevanagari(),
            ),
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
        title: Text(
          'बाहेर पडा',
          style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'तुम्हाला नक्की बाहेर पडायचे आहे का?',
          style: GoogleFonts.notoSansDevanagari(),
        ),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}