import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/farmer_model.dart';

class FarmerSearchScreen extends StatefulWidget {
  const FarmerSearchScreen({super.key});

  @override
  State<FarmerSearchScreen> createState() => _FarmerSearchScreenState();
}

class _FarmerSearchScreenState extends State<FarmerSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF6F00).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'शेतकरी शोध',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Farmer Search',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'नाव, गाव किंवा फोन नंबर शोधा...',
                      hintStyle: GoogleFonts.notoSansDevanagari(fontSize: 14, color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Color(0xFFFF6F00), size: 24),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFF6F00), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.trim());
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFFF6F00).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFFF6F00), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'सर्व नोंदणीकृत शेतकरी',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6F00),
                          ),
                        ),
                        Text(
                          'All registered farmers are listed here',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xFFFF6F00).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Farmers List
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildAllFarmers()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  // ✅ Show all farmers from Firebase
  Widget _buildAllFarmers() {
    return StreamBuilder<List<FarmerModel>>(
      stream: FirebaseService.getAllFarmers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final farmers = snapshot.data ?? [];

        if (farmers.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: farmers.length,
          itemBuilder: (context, index) {
            final farmer = farmers[index];
            return _buildFarmerCard(farmer);
          },
        );
      },
    );
  }

  // ✅ Search farmers from Firebase
  Widget _buildSearchResults() {
    return StreamBuilder<List<FarmerModel>>(
      stream: FirebaseService.getAllFarmers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final allFarmers = snapshot.data ?? [];

        // ✅ Filter farmers locally (search by name, village, phone)
        final filteredFarmers = allFarmers.where((farmer) {
          final query = _searchQuery.toLowerCase();
          return farmer.name.toLowerCase().contains(query) ||
              farmer.village.toLowerCase().contains(query) ||
              farmer.phoneNumber.contains(query);
        }).toList();

        if (filteredFarmers.isEmpty) {
          return _buildNoResultsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: filteredFarmers.length,
          itemBuilder: (context, index) {
            final farmer = filteredFarmers[index];
            return _buildFarmerCard(farmer);
          },
        );
      },
    );
  }

  Widget _buildFarmerCard(FarmerModel farmer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFarmerDetails(farmer),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6F00), Color(0xFFFFA000)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      farmer.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.name,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            farmer.village,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            farmer.phoneNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lands Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6F00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${farmer.landIds.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                      Text(
                        'जमीन',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 10,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Arrow
                Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFF6F00)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFarmerDetails(FarmerModel farmer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6F00), Color(0xFFFFA000)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                farmer.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            farmer.name,
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Color(0xFFFFCC80)!),
                            ),
                            child: Text(
                              'नोंदणीकृत शेतकरी',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 12,
                                color: Color(0xFFFF6F00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info Section
                    Text(
                      'माहिती',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6F00),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoTile(Icons.location_on, 'गाव', farmer.village),
                    _buildInfoTile(Icons.phone, 'फोन नंबर', farmer.phoneNumber),
                    if (farmer.alternatePhone != null && farmer.alternatePhone!.isNotEmpty)
                      _buildInfoTile(
                        Icons.phone_android,
                        'पर्यायी फोन',
                        farmer.alternatePhone!,
                      ),
                    _buildInfoTile(
                      Icons.credit_card,
                      'आधार क्रमांक',
                      farmer.aadhaarNumber,
                    ),
                    _buildInfoTile(
                      Icons.calendar_today,
                      'नोंदणी तारीख',
                      DateFormat('dd MMM yyyy').format(farmer.registrationDate),
                    ),
                    _buildInfoTile(
                      Icons.landscape,
                      'एकूण जमीन',
                      '${farmer.landIds.length} जमीन',
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        // View Lands Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to farmer's lands view
                            },
                            icon: const Icon(Icons.landscape, size: 20),
                            label: Text(
                              'जमीन पाहा',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F00),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Delete Button
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: IconButton(
                            onPressed: _isDeleting ? null : () {
                              Navigator.pop(context);
                              _confirmDeleteFarmer(farmer);
                            },
                            icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 24),
                            tooltip: 'शेतकरी हटवा',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6F00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFF6F00), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
          ),
          const SizedBox(height: 16),
          Text(
            'शेतकरी लोड होत आहेत...',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'त्रुटी आली',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'पुन्हा प्रयत्न करा',
              style: GoogleFonts.notoSansDevanagari(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6F00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'अद्याप शेतकरी नाहीत',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'नोंदणीकृत शेतकरी येथे दिसतील',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'शेतकरी सापडले नाहीत',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'वेगळ्या कीवर्डसह शोधण्याचा प्रयत्न करा',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFarmer(FarmerModel farmer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber, size: 40, color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              Text(
                'शेतकरी हटवायचा आहे?',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'तुम्ही ${farmer.name} या शेतकऱ्याला हटवणार आहात. ही क्रिया मागे घेता येणार नाही.',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        'रद्द करा',
                        style: GoogleFonts.notoSansDevanagari(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDeleting ? null : () => _deleteFarmer(farmer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isDeleting
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'हटवा',
                        style: GoogleFonts.notoSansDevanagari(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteFarmer(FarmerModel farmer) async {
    setState(() => _isDeleting = true);

    try {
      // Close confirmation dialog first
      Navigator.of(context).pop();

      // Wait a moment for dialog to close
      await Future.delayed(const Duration(milliseconds: 100));

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'शेतकरी हटवला जात आहे...',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'कृपया प्रतीक्षा करा',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Delete farmer from Firebase
      await FirebaseService.deleteFarmer(farmer.id);

      // Close loading dialog safely
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Wait before showing snackbar
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✅ ${farmer.name} यशस्वीरित्या हटवला',
                  style: GoogleFonts.notoSansDevanagari(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog safely
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '❌ त्रुटी: ${e.toString()}',
                  style: GoogleFonts.notoSansDevanagari(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}