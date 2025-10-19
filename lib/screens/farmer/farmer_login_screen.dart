import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firebase_service.dart';
import 'farmer_home_screen.dart';
import 'farmer_registration_screen.dart';

class FarmerLoginScreen extends StatefulWidget {
  const FarmerLoginScreen({super.key});

  @override
  State<FarmerLoginScreen> createState() => _FarmerLoginScreenState();
}

class _FarmerLoginScreenState extends State<FarmerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final aadhaarNumber = _aadhaarController.text.trim().replaceAll(' ', '');

      // ✅ Check if farmer exists
      final farmer = await FirebaseService.getFarmerByAadhaar(aadhaarNumber);

      if (farmer == null) {
        // ❌ Farmer not found - Go to registration
        setState(() => _isLoading = false);

        if (!mounted) return;

        final shouldRegister = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: Column(
              children: [
                Icon(Icons.person_add, size: 50, color: Color(0xFF2E7D32)),
                SizedBox(height: 8),
                Text(
                  'नोंदणी नाही',
                  style: GoogleFonts.notoSansDevanagari(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            content: Text(
              'हा आधार क्रमांक नोंदणीकृत नाही. नवीन नोंदणी करायची आहे का?',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansDevanagari(fontSize: 14),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey),
                      ),
                      child: Text('रद्द करा', style: GoogleFonts.notoSansDevanagari()),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E7D32),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('नोंदणी करा', style: GoogleFonts.notoSansDevanagari(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (shouldRegister == true && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FarmerRegistrationScreen()),
          );
        }
        return;
      }

      // ✅ Farmer found - Login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farmerId', farmer.id);
      await prefs.setBool('isRegistered', true);
      await prefs.setBool('isAdmin', false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ स्वागत आहे, ${farmer.name}!',
            style: GoogleFonts.notoSansDevanagari(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ त्रुटी: $e', style: GoogleFonts.notoSansDevanagari()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32).withOpacity(0.1),
              Color(0xFF66BB6A).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header Section with Back Button
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'शेतकरी लॉगिन',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Spacer(),
                    SizedBox(width: 48), // For balance
                  ],
                ),

                SizedBox(height: 40),

                // Welcome Illustration
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2E7D32).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.agriculture, size: 60, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Welcome Text
                Column(
                  children: [
                    Text(
                      'आपले स्वागत आहे!',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'आधार क्रमांक वापरून लॉगिन करा',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // Login Form Card
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Aadhaar Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: TextFormField(
                            controller: _aadhaarController,
                            keyboardType: TextInputType.number,
                            maxLength: 14,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              AadhaarInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: 'आधार कार्ड नंबर',
                              labelStyle: GoogleFonts.notoSansDevanagari(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: 'XXXX XXXX XXXX',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              prefixIcon: Container(
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2E7D32).withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Icon(Icons.credit_card, color: Color(0xFF2E7D32)),
                              ),
                              prefixIconConstraints: BoxConstraints(minWidth: 60),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                              ),
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
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
                        ),

                        SizedBox(height: 32),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Color(0xFF2E7D32).withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? SizedBox(
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
                                Icon(Icons.login, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'लॉगिन करा',
                                  style: GoogleFonts.notoSansDevanagari(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Info Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF90CAF9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1976D2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.info_outline, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'नवीन शेतकरी?',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'आधार क्रमांक टाका आणि आपोआप नोंदणी सुरू होईल!',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 12,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Footer
                Text(
                  'शेतसखा - शेतकऱ्यांसाठी डिजिटल सोल्यूशन',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Aadhaar formatter
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