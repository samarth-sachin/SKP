import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirebaseService().getAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = snapshot.data ?? {};
        final cropCounts =
            analytics['cropCounts'] as Map<String, int>? ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Analytics',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFinancialSummary(analytics),
              const SizedBox(height: 24),
              Text(
                'Top Crops',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildCropsList(cropCounts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialSummary(Map<String, dynamic> analytics) {
    final totalRevenue =
        (analytics['totalCredit'] ?? 0) + (analytics['totalCash'] ?? 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow(
              'Total Revenue',
              '₹${totalRevenue.toStringAsFixed(2)}',
              Colors.green,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Cash Collected',
              '₹${(analytics['totalCash'] ?? 0).toStringAsFixed(2)}',
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Credit Pending',
              '₹${(analytics['totalCredit'] ?? 0).toStringAsFixed(2)}',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCropsList(Map<String, int> cropCounts) {
    if (cropCounts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No crop data available')),
        ),
      );
    }

    final sortedCrops = cropCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCrops.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.grass, color: Color(0xFF2E7D32)),
            title: Text(entry.key),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${entry.value} lands',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
