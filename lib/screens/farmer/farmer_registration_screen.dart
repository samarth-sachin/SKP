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

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _aadhaarController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _registerFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Check if primary and alternate phone numbers are the same
    final primaryPhone = _phoneController.text.trim();
    final alternatePhone = _alternatePhoneController.text.trim();

    if (alternatePhone.isNotEmpty && primaryPhone == alternatePhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '❌ प्राथमिक आणि पर्यायी नंबर समान असू शकत नाही!',
                  style: GoogleFonts.notoSansDevanagari(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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

        _showSuccessDialog(
          'स्वागत आहे!',
          '${existingFarmer.name}, तुमची नोंदणी आधीच झाली आहे.',
          true,
        );
        return;
      }

      // ✅ New farmer - Register
      final farmer = FarmerModel(
        id: '',
        name: _nameController.text.trim(),
        village: _villageController.text.trim(),
        phoneNumber: primaryPhone,
        alternatePhone: alternatePhone.isEmpty ? null : alternatePhone,
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

      _showSuccessDialog(
        'नोंदणी यशस्वी! 🎉',
        'तुमची नोंदणी यशस्वीरित्या पूर्ण झाली आहे.',
        false,
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      _showErrorDialog('नोंदणी अयशस्वी', 'त्रुटी: $e');
    }
  }

  void _showSuccessDialog(String title, String message, bool isExistingUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2E7D32),
                const Color(0xFF4CAF50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  isExistingUser ? Icons.check_circle : Icons.celebration,
                  color: const Color(0xFF2E7D32),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'चालू ठेवा',
                  style: GoogleFonts.notoSansDevanagari(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD32F2F),
                const Color(0xFFF44336),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFD32F2F),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'पुन्हा प्रयत्न करा',
                  style: GoogleFonts.notoSansDevanagari(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 32,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'नवीन शेतकरी नोंदणी',
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'New Farmer Registration',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'सर्व फील्ड भरणे अनिवार्य आहे',
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Name field
                        _buildTextField(
                          controller: _nameController,
                          label: 'पूर्ण नाव *',
                          hint: 'आपले पूर्ण नाव प्रविष्ट करा',
                          icon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'कृपया नाव प्रविष्ट करा';
                            }
                            if (value.length < 3) {
                              return 'नाव किमान ३ अक्षरांचे असावे';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Village field
                        _buildTextField(
                          controller: _villageController,
                          label: 'गाव *',
                          hint: 'आपले गाव प्रविष्ट करा',
                          icon: Icons.location_on_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'कृपया गाव प्रविष्ट करा';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Phone field
                        _buildTextField(
                          controller: _phoneController,
                          label: 'मोबाईल नंबर *',
                          hint: '९८७६५४३२१०',
                          icon: Icons.phone_rounded,
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
                            if (!value.startsWith(RegExp(r'[6-9]'))) {
                              return 'वैध मोबाईल नंबर प्रविष्ट करा';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Alternate Phone field (optional)
                        _buildTextField(
                          controller: _alternatePhoneController,
                          label: 'पर्यायी मोबाईल नंबर',
                          hint: 'पर्यायी नंबर (ऐच्छिक)',
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length != 10) {
                                return 'पर्यायी नंबर 10 अंकी असावा';
                              }
                              if (!value.startsWith(RegExp(r'[6-9]'))) {
                                return 'वैध मोबाईल नंबर प्रविष्ट करा';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Aadhaar field
                        _buildTextField(
                          controller: _aadhaarController,
                          label: 'आधार कार्ड नंबर *',
                          hint: '१२३४ ५६७८ ९०१२',
                          icon: Icons.credit_card_rounded,
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

                        const SizedBox(height: 24),

                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.green[700], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'महत्वाचे सूचना:',
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '• * चिन्ह असलेले फील्ड भरणे अनिवार्य आहे\n• प्राथमिक आणि पर्यायी नंबर समान असू शकत नाही\n• आधार नंबर आधीच वापरात असल्यास स्वयं लॉगिन होईल',
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontSize: 12,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ],
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: Colors.green.withOpacity(0.3),
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
                                const Icon(Icons.app_registration_rounded, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'नोंदणी करा',
                                  style: GoogleFonts.notoSansDevanagari(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Footer
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.security_rounded, color: Colors.green[700], size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'तुमची माहिती सुरक्षित आहे',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLength: maxLength,
          style: GoogleFonts.poppins(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSansDevanagari(
              color: Colors.grey[500],
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32)),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
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