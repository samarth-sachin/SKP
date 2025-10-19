import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/land_model.dart';
import '../../models/dose_model.dart';
import '../../services/firebase_service.dart';

class LandDetailsScreen extends StatelessWidget {
  final LandModel land;

  const LandDetailsScreen({super.key, required this.land});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(land.landName),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandInfoCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'डोस इतिहास / Dose History',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDoseHistory(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFFA5D6A7)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.landscape,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      land.landName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      land.location,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.grass,
            label: 'सध्याचे पीक / Current Crop',
            value: land.currentCrop,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.straighten,
            label: 'क्षेत्रफळ / Area',
            value: '${land.areaInAcres} एकर',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDoseHistory(BuildContext context) {
    // ✅ Get doses from Firebase in real-time
    return StreamBuilder<List<DoseModel>>(
      stream: FirebaseService.getDosesForLand(land.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final doses = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: doses.length,
          itemBuilder: (context, index) {
            final dose = doses[index];
            return _buildDoseCard(dose);
          },
        );
      },
    );
  }

  Widget _buildDoseCard(DoseModel dose) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'डोस ${dose.doseNumber}',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: dose.paymentType == 'Credit'
                        ? Colors.orange[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        dose.paymentType == 'Credit'
                            ? Icons.credit_card
                            : Icons.payments,
                        size: 16,
                        color: dose.paymentType == 'Credit'
                            ? Colors.orange[800]
                            : Colors.green[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dose.paymentType == 'Credit' ? 'उधार' : 'रोख',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: dose.paymentType == 'Credit'
                              ? Colors.orange[800]
                              : Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDoseInfoRow(
              icon: Icons.calendar_today,
              label: 'तारीख / Date',
              value: DateFormat('dd MMM yyyy').format(dose.applicationDate),
            ),
            const SizedBox(height: 8),
            _buildDoseInfoRow(
              icon: Icons.currency_rupee,
              label: 'रक्कम / Amount',
              value: '₹${dose.amount.toStringAsFixed(2)}',
            ),
            if (dose.nextDoseDate != null) ...[
              const SizedBox(height: 8),
              _buildDoseInfoRow(
                icon: Icons.notification_important,
                label: 'पुढील डोस / Next Dose',
                value: DateFormat('dd MMM yyyy').format(dose.nextDoseDate!),
                valueColor: Colors.orange,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'वापरलेली खते / Fertilizers Used:',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...dose.fertilizers.map((fert) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    '${fert.name}: ${fert.quantity} ${fert.unit}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            )),
            if (dose.notes != null && dose.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dose.notes!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Payment status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: dose.isPaid ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: dose.isPaid ? Colors.green[300]! : Colors.red[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    dose.isPaid ? Icons.check_circle : Icons.pending,
                    size: 16,
                    color: dose.isPaid ? Colors.green[700] : Colors.red[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dose.isPaid ? 'देयक भरले / Paid' : 'देयक बाकी / Pending',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: dose.isPaid ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.water_drop_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'अद्याप डोस नाही',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No doses applied yet',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            'डोस इतिहास येथे दिसेल',
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
}
