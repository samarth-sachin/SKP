import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/local_storage_service.dart';
import '../../models/land_model.dart';

class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _landNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  
  String _selectedCrop = 'Cotton';
  bool _isLoading = false;

  final List<String> _crops = [
    'Cotton',
    'Sugarcane',
    'Wheat',
    'Rice',
    'Soybean',
    'Maize',
    'Groundnut',
    'Onion',
    'Tomato',
    'Chilli',
    'Grapes',
    'Pomegranate',
    'Banana',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'नवीन जमीन जोडा',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            Text(
              'Add New Land',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'आपली जमीन नोंदवा',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            Text(
                              'खत डोस ट्रॅक करण्यासाठी जमिनीचा तपशील द्या',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Land Name
                Text(
                  'जमिनीचे नाव / Land Name',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _landNameController,
                  decoration: InputDecoration(
                    hintText: 'उदा: पूर्व शेत, मुख्य जमीन',
                    hintStyle: GoogleFonts.notoSansDevanagari(fontSize: 13),
                    prefixIcon: const Icon(Icons.landscape, color: Color(0xFF2E7D32)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया जमिनीचे नाव प्रविष्ट करा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Location
                Text(
                  'ठिकाण / Location',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'उदा: नदीजवळ, मुख्य रस्त्यावर',
                    hintStyle: GoogleFonts.notoSansDevanagari(fontSize: 13),
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया ठिकाण प्रविष्ट करा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Current Crop
                Text(
                  'सध्याचे पीक / Current Crop',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCrop,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32)),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      items: _crops.map((String crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Row(
                            children: [
                              const Icon(Icons.grass, size: 18, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 12),
                              Text(crop),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCrop = newValue!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Area
                Text(
                  'क्षेत्रफळ (एकर) / Area (Acres)',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'उदा: 5.5',
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    prefixIcon: const Icon(Icons.straighten, color: Color(0xFF2E7D32)),
                    suffixText: 'एकर / acres',
                    suffixStyle: GoogleFonts.notoSansDevanagari(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया क्षेत्रफळ प्रविष्ट करा';
                    }
                    if (double.tryParse(value) == null) {
                      return 'कृपया वैध संख्या प्रविष्ट करा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitLand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'जमीन जोडा / Add Land',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitLand() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final storageService = Provider.of<LocalStorageService>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final farmerId = prefs.getString('farmerId') ?? '1';

      final newLand = LandModel(
        id: '',
        farmerId: farmerId,
        landName: _landNameController.text.trim(),
        location: _locationController.text.trim(),
        currentCrop: _selectedCrop,
        areaInAcres: double.parse(_areaController.text.trim()),
        doseHistory: [],
      );

      await storageService.addLand(newLand);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'जमीन यशस्वीरित्या जोडली!',
                  style: GoogleFonts.notoSansDevanagari(),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'त्रुटी: $e',
              style: GoogleFonts.notoSansDevanagari(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _landNameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    super.dispose();
  }
}
