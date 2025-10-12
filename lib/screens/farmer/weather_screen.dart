import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/weather_service.dart';
import '../../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _currentWeather;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);
    try {
      // You can replace with user's village name or use location coordinates
      final weather = await _weatherService.getCurrentWeather('Mumbai');
      setState(() {
        _currentWeather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load weather data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildWeatherContent(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            _errorMessage,
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadWeather,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_currentWeather == null) return const SizedBox();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainWeatherCard(),
            const SizedBox(height: 20),
            Text(
              'Weather Details / हवामान तपशील',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildWeatherDetails(),
            const SizedBox(height: 20),
            _buildFarmingAdvice(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFFA5D6A7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _currentWeather!.cityName,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Icon(
            _getWeatherIcon(_currentWeather!.description),
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            '${_currentWeather!.temperature.round()}°C',
            style: GoogleFonts.poppins(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentWeather!.description.toUpperCase(),
            style: GoogleFonts.nunito(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.water_drop,
                label: 'Humidity\nआर्द्रता',
                value: '${_currentWeather!.humidity}%',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.air,
                label: 'Wind Speed\nवारा',
                value: '${_currentWeather!.windSpeed} km/h',
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.cloud,
                label: 'Rain Chance\nपाऊस',
                value: '${_currentWeather!.rainChance}%',
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.thermostat,
                label: 'Feels Like\nजाणवतो',
                value: '${_currentWeather!.temperature.round()}°C',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingAdvice() {
    String advice = _getFarmingAdvice();
    IconData adviceIcon = _getAdviceIcon();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(adviceIcon, size: 40, color: Colors.amber[800]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farming Advice / सल्ला',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.amber[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    if (description.contains('rain')) return Icons.thunderstorm;
    if (description.contains('cloud')) return Icons.cloud;
    if (description.contains('clear')) return Icons.wb_sunny;
    if (description.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }

  String _getFarmingAdvice() {
    if (_currentWeather!.rainChance > 70) {
      return 'Heavy rain expected. Postpone fertilizer application.';
    } else if (_currentWeather!.temperature > 35) {
      return 'Very hot. Water crops early morning or evening.';
    } else if (_currentWeather!.humidity < 30) {
      return 'Low humidity. Increase irrigation frequency.';
    } else {
      return 'Good weather for farming activities.';
    }
  }

  IconData _getAdviceIcon() {
    if (_currentWeather!.rainChance > 70) return Icons.warning_amber;
    if (_currentWeather!.temperature > 35) return Icons.local_fire_department;
    return Icons.check_circle;
  }
}
