import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/fertilizer_database.dart';
import '../../models/fertilizer_info_model.dart';
import 'fertilizer_details_screen.dart';

class FertilizerInfoScreen extends StatefulWidget {
  const FertilizerInfoScreen({super.key});

  @override
  State<FertilizerInfoScreen> createState() => _FertilizerInfoScreenState();
}

class _FertilizerInfoScreenState extends State<FertilizerInfoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<FertilizerInfo> _allFertilizers = [];
  List<FertilizerInfo> _filteredFertilizers = [];

  @override
  void initState() {
    super.initState();
    _allFertilizers = FertilizerDatabase.getAllFertilizers();
    _filteredFertilizers = _allFertilizers;
  }

  void _filterFertilizers() {
    setState(() {
      _filteredFertilizers = _allFertilizers.where((fertilizer) {
        final matchesSearch = _searchQuery.isEmpty ||
            fertilizer.nameEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            fertilizer.nameMarathi.contains(_searchQuery) ||
            fertilizer.company.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory = _selectedCategory == 'All' ||
            fertilizer.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'खत माहिती',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            Text(
              'Fertilizer Information',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF2E7D32)),
            onPressed: _showCategoryFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _filterFertilizers();
              },
              decoration: InputDecoration(
                hintText: 'खत शोधा / Search fertilizer...',
                hintStyle: GoogleFonts.notoSansDevanagari(fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _filterFertilizers();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Category Chips
          if (_selectedCategory != 'All')
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      _selectedCategory,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF2E7D32),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() => _selectedCategory = 'All');
                      _filterFertilizers();
                    },
                  ),
                ],
              ),
            ),

          // Results Count
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  '${_filteredFertilizers.length} खत उपलब्ध',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  ' • ${_filteredFertilizers.length} fertilizers available',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Fertilizer List
          Expanded(
            child: _filteredFertilizers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFertilizers.length,
                    itemBuilder: (context, index) {
                      final fertilizer = _filteredFertilizers[index];
                      return _buildFertilizerCard(fertilizer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerCard(FertilizerInfo fertilizer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FertilizerDetailsScreen(fertilizer: fertilizer),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon based on category
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(fertilizer.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(fertilizer.category),
                        color: _getCategoryColor(fertilizer.category),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fertilizer.nameMarathi,
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fertilizer.nameEnglish,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF2E7D32),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    fertilizer.company,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fertilizer.purposeMarathi,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: fertilizer.suitableFor.take(3).map((crop) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        crop,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.blue[800],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'खत सापडले नाही',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No fertilizers found',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'प्रकार निवडा / Select Category',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCategoryOption('All', 'सर्व'),
                      ...FertilizerDatabase.getCategories().map((category) {
                        return _buildCategoryOption(category, category);
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryOption(String category, String marathi) {
    final isSelected = _selectedCategory == category;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[400],
      ),
      title: Text(
        marathi,
        style: GoogleFonts.notoSansDevanagari(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
        ),
      ),
      onTap: () {
        setState(() => _selectedCategory = category);
        _filterFertilizers();
        Navigator.pop(context);
      },
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
