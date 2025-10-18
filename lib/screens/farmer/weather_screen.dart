import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _error = '';
  String _currentLocation = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // ✅ Step 1: Get current location
      Position position = await _getCurrentLocation();
      
      print('📍 Location: ${position.latitude}, ${position.longitude}');

      const apiKey = '2873b07f90164f928c3143103251710';
      
      // ✅ Step 2: Use coordinates instead of city name
      final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}&aqi=no';

      print('🌤️ Fetching weather from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = data;
          _currentLocation = '${data['location']['name']}, ${data['location']['region']}';
          _isLoading = false;
        });
        print('✅ Weather data loaded successfully for $_currentLocation');
      } else {
        setState(() {
          _error = 'API Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Exception: $e');
      setState(() {
        _error = e.toString().contains('location') 
            ? 'Location permission denied' 
            : 'कनेक्शन त्रुटी';
        _isLoading = false;
      });
    }
  }

  // ✅ Get current GPS location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('sunny') || condition.contains('clear')) {
      return '☀️';
    } else if (condition.contains('cloud')) {
      return '☁️';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return '🌧️';
    } else if (condition.contains('snow')) {
      return '❄️';
    } else if (condition.contains('thunder')) {
      return '⛈️';
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return '🌫️';
    }
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? _buildLoading()
          : _error.isNotEmpty
              ? _buildError()
              : _buildWeatherContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          Text(
            'तुमचे ठिकाण शोधत आहे...',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting your location...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _error.contains('location') || _error.contains('permission')
                  ? Icons.location_off
                  : Icons.cloud_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _error.contains('location') || _error.contains('permission')
                  ? 'Location Permission Required'
                  : 'Connection Error',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _error.contains('location') || _error.contains('permission')
                  ? 'कृपया Location permission द्या'
                  : _error,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_error.contains('location') || _error.contains('permission'))
              ElevatedButton.icon(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                icon: const Icon(Icons.settings),
                label: Text(
                  'Settings उघडा',
                  style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchWeatherData,
              icon: const Icon(Icons.refresh),
              label: Text(
                'पुन्हा प्रयत्न करा',
                style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_weatherData == null) return _buildError();

    final current = _weatherData!['current'];
    final location = _weatherData!['location'];
    final condition = current['condition'];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with Location
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Location with GPS icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.my_location, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${location['name']}, ${location['region']}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _getWeatherIcon(condition['text']),
                  style: const TextStyle(fontSize: 100),
                ),
                const SizedBox(height: 20),
                Text(
                  '${current['temp_c'].round()}°C',
                  style: GoogleFonts.poppins(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  condition['text'].toString().toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Feels like ${current['feelslike_c'].round()}°C',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Weather Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'हवामान तपशील',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weather Details',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.water_drop,
                        label: 'आर्द्रता\nHumidity',
                        value: '${current['humidity']}%',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.air,
                        label: 'वारा\nWind',
                        value: '${current['wind_kph']} km/h',
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.compress,
                        label: 'दबाव\nPressure',
                        value: '${current['pressure_mb']} mb',
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.visibility,
                        label: 'दृश्यता\nVisibility',
                        value: '${current['vis_km']} km',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildFarmingAdvice(condition['text']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingAdvice(String weatherCondition) {
    String advice = '';
    String marathiAdvice = '';
    IconData adviceIcon = Icons.agriculture;
    Color adviceColor = Colors.green;

    weatherCondition = weatherCondition.toLowerCase();

    if (weatherCondition.contains('sunny') || weatherCondition.contains('clear')) {
      advice = 'Perfect weather for farming! Good day for irrigation and fieldwork.';
      marathiAdvice = 'उत्तम हवामान! सिंचन आणि शेतकामासाठी चांगला दिवस.';
      adviceIcon = Icons.wb_sunny;
      adviceColor = Colors.amber;
    } else if (weatherCondition.contains('rain')) {
      advice = 'Rainy weather. Good for soil moisture but avoid chemical spraying.';
      marathiAdvice = 'पावसाळी हवामान. मातीतील ओलावा चांगला पण रासायनिक फवारणी टाळा.';
      adviceIcon = Icons.umbrella;
      adviceColor = Colors.blue;
    } else if (weatherCondition.contains('cloud')) {
      advice = 'Cloudy weather. Suitable for planting and transplanting.';
      marathiAdvice = 'ढगाळ हवामान. लागवड आणि रोपांसाठी योग्य.';
      adviceIcon = Icons.cloud;
      adviceColor = Colors.grey;
    } else {
      advice = 'Normal farming activities can be carried out today.';
      marathiAdvice = 'सामान्य शेती कामे आज करू शकता.';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [adviceColor.withOpacity(0.1), adviceColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: adviceColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: adviceColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(adviceIcon, size: 32, color: adviceColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'शेती सल्ला',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: adviceColor.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Farming Advice',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  marathiAdvice,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
