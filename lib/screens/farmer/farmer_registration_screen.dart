import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/farmer_model.dart';
import '../../services/firebase_service.dart';
import 'farmer_home_screen.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({super.key});

  @override
  State<FarmerRegistrationScreen> createState() => _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _aadhaarController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _registerFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final aadhaarNumber = _aadhaarController.text.trim().replaceAll(' ', '');

      // ✅ Check if Aadhaar already exists
      final existingFarmer = await FirebaseService.getFarmerByAadhaar(aadhaarNumber);

      if (existingFarmer != null) {
        // ✅ Farmer already registered - Auto login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('farmerId', existingFarmer.id);
        await prefs.setBool('isRegistered', true);
        await prefs.setBool('isAdmin', false);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ स्वागत आहे, ${existingFarmer.name}! तुमची नोंदणी आधीच झाली आहे.',
              style: GoogleFonts.notoSansDevanagari(),
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
        );
        return;
      }

      // ✅ New farmer - Register
      final farmer = FarmerModel(
        id: '',
        name: _nameController.text.trim(),
        village: _villageController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        alternatePhone: _alternatePhoneController.text.trim().isEmpty
            ? null
            : _alternatePhoneController.text.trim(),
        aadhaarNumber: aadhaarNumber,
        registrationDate: DateTime.now(),
        landIds: [],
      );

      // ✅ Save to Firebase
      final farmerId = await FirebaseService.registerFarmer(farmer);

      // Save farmer ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farmerId', farmerId);
      await prefs.setBool('isRegistered', true);
      await prefs.setBool('isAdmin', false);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ नोंदणी यशस्वी! Registration Successful!',
            style: GoogleFonts.notoSansDevanagari(),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ नोंदणी अयशस्वी: $e',
            style: GoogleFonts.notoSansDevanagari(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          'शेतकरी नोंदणी',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_add, size: 40, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'नवीन शेतकरी नोंदणी',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'New Farmer Registration',
                              style: GoogleFonts.poppins(
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

                const SizedBox(height: 24),

                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'पूर्ण नाव / Full Name *',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया नाव प्रविष्ट करा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Village field
                _buildTextField(
                  controller: _villageController,
                  label: 'गाव / Village *',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया गाव प्रविष्ट करा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone field
                _buildTextField(
                  controller: _phoneController,
                  label: 'मोबाईल नंबर / Mobile Number *',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया मोबाईल नंबर प्रविष्ट करा';
                    }
                    if (value.length != 10) {
                      return 'मोबाईल नंबर 10 अंकी असावा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Alternate Phone field (optional)
                _buildTextField(
                  controller: _alternatePhoneController,
                  label: 'पर्यायी नंबर / Alternate Number (Optional)',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length != 10) {
                      return 'पर्यायी नंबर 10 अंकी असावा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ✅ Aadhaar field - REQUIRED (as per your model)
                _buildTextField(
                  controller: _aadhaarController,
                  label: 'आधार कार्ड नंबर / Aadhaar Number *',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    AadhaarInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया आधार कार्ड नंबर प्रविष्ट करा';
                    }
                    final digits = value.replaceAll(' ', '');
                    if (digits.length != 12) {
                      return 'आधार कार्ड नंबर 12 अंकी असावा';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '* चिन्हाचे सर्व फील्ड भरणे आवश्यक आहे',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerFarmer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
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
                        : Text(
                      'नोंदणी करा / Register',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLength: maxLength,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.notoSansDevanagari(fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        counterText: '',
      ),
    );
  }
}

// Aadhaar formatter (adds spaces after every 4 digits)
class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 12) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
