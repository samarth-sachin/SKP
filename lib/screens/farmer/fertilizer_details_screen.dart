import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/fertilizer_info_model.dart';

class FertilizerDetailsScreen extends StatelessWidget {
  final FertilizerInfo fertilizer;

  const FertilizerDetailsScreen({super.key, required this.fertilizer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getCategoryColor(fertilizer.category),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                fertilizer.nameMarathi,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(fertilizer.category),
                      _getCategoryColor(fertilizer.category).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      _getCategoryIcon(fertilizer.category),
                      size: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  _buildInfoCard(
                    title: 'मूलभूत माहिती',
                    subtitle: 'Basic Information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.label,
                        labelMarathi: 'इंग्रजी नाव',
                        labelEnglish: 'English Name',
                        value: fertilizer.nameEnglish,
                      ),
                      _buildInfoRow(
                        icon: Icons.business,
                        labelMarathi: 'कंपनी',
                        labelEnglish: 'Company',
                        value: fertilizer.company,
                      ),
                      _buildInfoRow(
                        icon: Icons.category,
                        labelMarathi: 'प्रकार',
                        labelEnglish: 'Category',
                        value: fertilizer.category,
                      ),
                      _buildInfoRow(
                        icon: Icons.science,
                        labelMarathi: 'संरचना',
                        labelEnglish: 'Composition',
                        value: fertilizer.composition,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Purpose Card
                  _buildInfoCard(
                    title: 'उद्देश',
                    subtitle: 'Purpose',
                    children: [
                      Text(
                        fertilizer.purposeMarathi,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fertilizer.purpose,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Benefits Card
                  _buildInfoCard(
                    title: 'फायदे',
                    subtitle: 'Benefits',
                    children: [
                      ...fertilizer.benefitsMarathi.asMap().entries.map((entry) {
                        final index = entry.key;
                        final benefitMarathi = entry.value;
                        final benefitEnglish = fertilizer.benefits[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.green[700],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      benefitMarathi,
                                      style: GoogleFonts.notoSansDevanagari(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      benefitEnglish,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Dosage Card
                  _buildInfoCard(
                    title: 'प्रमाण आणि वापर',
                    subtitle: 'Dosage & Application',
                    children: [
                      _buildApplicationDetail(
                        icon: Icons.scale,
                        titleMarathi: 'प्रमाण',
                        titleEnglish: 'Dosage',
                        valueMarathi: fertilizer.dosageMarathi,
                        valueEnglish: fertilizer.dosage,
                        color: Colors.orange,
                      ),
                      const Divider(height: 24),
                      _buildApplicationDetail(
                        icon: Icons.water_drop,
                        titleMarathi: 'वापर पद्धत',
                        titleEnglish: 'Application Method',
                        valueMarathi: fertilizer.applicationMethodMarathi,
                        valueEnglish: fertilizer.applicationMethod,
                        color: Colors.blue,
                      ),
                      const Divider(height: 24),
                      _buildApplicationDetail(
                        icon: Icons.calendar_today,
                        titleMarathi: 'योग्य वेळ',
                        titleEnglish: 'Timing',
                        valueMarathi: fertilizer.timingMarathi,
                        valueEnglish: fertilizer.timing,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Suitable Crops Card
                  _buildInfoCard(
                    title: 'योग्य पिके',
                    subtitle: 'Suitable Crops',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: fertilizer.suitableFor.map((crop) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.grass,
                                  size: 16,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  crop,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add to dose entry
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'डोस नोंदणीमध्ये जोडले',
                style: GoogleFonts.notoSansDevanagari(),
              ),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add),
        label: Text(
          'डोसमध्ये जोडा',
          style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String labelMarathi,
    required String labelEnglish,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$labelMarathi / $labelEnglish',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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

  Widget _buildApplicationDetail({
    required IconData icon,
    required String titleMarathi,
    required String titleEnglish,
    required String valueMarathi,
    required String valueEnglish,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleMarathi,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                titleEnglish,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                valueMarathi,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              Text(
                valueEnglish,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Micronutrient Mixture':
      case 'Chelated Micronutrients':
      case 'Micronutrient':
        return Colors.orange;
      case 'Water Soluble NPK':
      case 'Secondary Nutrient':
        return Colors.blue;
      case 'Organic Carbon':
      case 'Bio-fertilizer':
        return Colors.green;
      case 'Plant Growth Promoter':
      case 'Bio-stimulant':
        return Colors.purple;
      case 'Plant Hormone':
      case 'Plant Growth Regulator':
        return Colors.pink;
      case 'Enzyme':
        return Colors.teal;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Micronutrient Mixture':
      case 'Chelated Micronutrients':
      case 'Micronutrient':
        return Icons.science;
      case 'Water Soluble NPK':
        return Icons.water_drop;
      case 'Organic Carbon':
      case 'Bio-fertilizer':
        return Icons.eco;
      case 'Plant Growth Promoter':
      case 'Bio-stimulant':
        return Icons.trending_up;
      case 'Plant Hormone':
        return Icons.spa;
      case 'Enzyme':
        return Icons.biotech;
      default:
        return Icons.grass;
    }
  }
}
