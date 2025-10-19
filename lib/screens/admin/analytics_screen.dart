import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/firebase_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getAnalyticsData(), // ✅ Get data from Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading analytics',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final analytics = snapshot.data ?? {};
          final cropCounts = analytics['cropCounts'] as Map<String, int>? ?? {};
          final totalCash = (analytics['totalCash'] ?? 0).toDouble();
          final totalCredit = (analytics['totalCredit'] ?? 0).toDouble();
          final totalRevenue = totalCash + totalCredit;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildRevenueOverview(totalRevenue, totalCash, totalCredit),
                const SizedBox(height: 24),
                _buildPaymentDistribution(totalCash, totalCredit, totalRevenue),
                const SizedBox(height: 24),
                _buildTopCropsSection(cropCounts),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Get analytics data from Firebase
  Future<Map<String, dynamic>> _getAnalyticsData() async {
    try {
      final doses = await FirebaseService.getAllDoses();
      final lands = await FirebaseService.getAllLands();

      double totalCash = 0;
      double totalCredit = 0;
      Map<String, int> cropCounts = {};

      // Calculate payment totals
      for (var dose in doses) {
        if (dose.paymentType == 'Cash') {
          totalCash += dose.amount;
        } else {
          totalCredit += dose.amount;
        }
      }

      // Count crops
      for (var land in lands) {
        cropCounts[land.currentCrop] = (cropCounts[land.currentCrop] ?? 0) + 1;
      }

      return {
        'totalCash': totalCash,
        'totalCredit': totalCredit,
        'cropCounts': cropCounts,
      };
    } catch (e) {
      print('❌ Error getting analytics: $e');
      return {
        'totalCash': 0.0,
        'totalCredit': 0.0,
        'cropCounts': <String, int>{},
      };
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 16),
          Text(
            'Analytics लोड होत आहे...',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'व्यवसाय विश्लेषण',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    'Business Analytics',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueOverview(double totalRevenue, double totalCash, double totalCredit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'एकूण उत्पन्न',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    'Total Revenue',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'All Time',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${totalRevenue.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildRevenueItem(
                  'रोख / Cash',
                  '₹${totalCash.toStringAsFixed(2)}',
                  Colors.green[100]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueItem(
                  'उधार / Credit',
                  '₹${totalCredit.toStringAsFixed(2)}',
                  Colors.orange[100]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDistribution(double totalCash, double totalCredit, double totalRevenue) {
    final data = [
      _ChartData('रोख / Cash', totalCash, const Color(0xFF4CAF50)),
      _ChartData('उधार / Credit', totalCredit, const Color(0xFFFF9800)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: Color(0xFF2E7D32), size: 24),
              const SizedBox(width: 8),
              Text(
                'देयक वितरण',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Payment Distribution',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          if (totalRevenue > 0)
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SfCircularChart(
                      palette: const [Color(0xFF4CAF50), Color(0xFFFF9800)],
                      series: <CircularSeries>[
                        DoughnutSeries<_ChartData, String>(
                          dataSource: data,
                          xValueMapper: (_ChartData data, _) => data.x,
                          yValueMapper: (_ChartData data, _) => data.y,
                          pointColorMapper: (_ChartData data, _) => data.color,
                          radius: '70%',
                          innerRadius: '60%',
                          dataLabelMapper: (_ChartData data, _) =>
                          '${((data.y / totalRevenue) * 100).toStringAsFixed(1)}%',
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.inside,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      annotations: <CircularChartAnnotation>[
                        CircularChartAnnotation(
                          widget: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '₹${totalRevenue.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('रोख / Cash', '₹${totalCash.toStringAsFixed(2)}',
                            const Color(0xFF4CAF50)),
                        const SizedBox(height: 16),
                        _buildLegendItem('उधार / Credit', '₹${totalCredit.toStringAsFixed(2)}',
                            const Color(0xFFFF9800)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'रोख प्रमाण',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${((totalCash / totalRevenue) * 100).toStringAsFixed(1)}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            _buildEmptyChartState(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChartState() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'अद्याप डेटा उपलब्ध नाही',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          Text(
            'No data available yet',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCropsSection(Map<String, int> cropCounts) {
    final sortedCrops = cropCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.agriculture, color: Color(0xFF2E7D32), size: 24),
              const SizedBox(width: 8),
              Text(
                'लोकप्रिय पिके',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Top Crops by Land Count',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          if (sortedCrops.isEmpty)
            _buildEmptyCropsState()
          else
            Column(
              children: sortedCrops.take(5).map((entry) {
                return _buildCropItem(entry.key, entry.value);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCropItem(String cropName, int landCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.grass, color: Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropName,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$landCount जमीन',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$landCount',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCropsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.agriculture_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'अद्याप पिकांचा डेटा नाही',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          Text(
            'No crop data available',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String x;
  final double y;
  final Color color;

  _ChartData(this.x, this.y, this.color);
}
