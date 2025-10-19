import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/farmer_model.dart';
import '../../models/land_model.dart';
import '../../models/dose_model.dart';

class AddDoseScreen extends StatefulWidget {
  const AddDoseScreen({super.key});

  @override
  State<AddDoseScreen> createState() => _AddDoseScreenState();
}

class _AddDoseScreenState extends State<AddDoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doseNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _farmerSearchController = TextEditingController();
  final _landSearchController = TextEditingController();

  FarmerModel? _selectedFarmer;
  LandModel? _selectedLand;
  String _paymentType = 'Cash';
  DateTime? _nextDoseDate;
  List<Fertilizer> _fertilizers = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _doseNumberController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _farmerSearchController.dispose();
    _landSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'नवीन डोस जोडा',
          style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressStep(1, 'शेतकरी', _selectedFarmer != null),
                  _buildProgressStep(2, 'जमीन', _selectedLand != null),
                  _buildProgressStep(3, 'डोस', _selectedLand != null),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('1. शेतकरी निवडा', 'Select Farmer'),
                    const SizedBox(height: 12),
                    _buildFarmerSelector(),

                    if (_selectedFarmer != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('2. जमीन निवडा', 'Select Land'),
                      const SizedBox(height: 12),
                      _buildLandSelector(),
                    ],

                    if (_selectedLand != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('3. डोस तपशील', 'Dose Details'),
                      const SizedBox(height: 12),
                      _buildDoseDetails(),

                      const SizedBox(height: 24),
                      _buildSectionTitle('4. वापरलेली खते', 'Fertilizers Used'),
                      const SizedBox(height: 12),
                      _buildFertilizersList(),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addFertilizer,
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: Text(
                            'खत जोडा / Add Fertilizer',
                            style: GoogleFonts.notoSansDevanagari(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[50],
                            foregroundColor: Colors.orange[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.orange[300]!),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('5. देयक तपशील', 'Payment Details'),
                      const SizedBox(height: 12),
                      _buildPaymentDetails(),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitDose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'डोस जतन करा / Submit Dose',
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
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.orange[800] : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
              '$step',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isCompleted ? Colors.orange[800] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String marathi, String english) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          marathi,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
          ),
        ),
        Text(
          english,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.orange[700],
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Real-time farmers from Firebase
            StreamBuilder<List<FarmerModel>>(
              stream: FirebaseService.getAllFarmers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'त्रुटी: ${snapshot.error}',
                      style: GoogleFonts.notoSansDevanagari(color: Colors.red),
                    ),
                  );
                }

                final allFarmers = snapshot.data ?? [];

                // Filter farmers based on search
                final query = _farmerSearchController.text.toLowerCase();
                final filteredFarmers = allFarmers.where((farmer) {
                  return farmer.name.toLowerCase().contains(query) ||
                      farmer.village.toLowerCase().contains(query) ||
                      farmer.phoneNumber.contains(query);
                }).toList();

                return Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _farmerSearchController,
                        decoration: InputDecoration(
                          hintText: 'शेतकरी शोधा...',
                          hintStyle: GoogleFonts.notoSansDevanagari(fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Farmers List
                    if (filteredFarmers.isEmpty)
                      _buildEmptyState('शेतकरी सापडले नाहीत', 'No farmers found')
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: filteredFarmers.length,
                          itemBuilder: (context, index) {
                            final farmer = filteredFarmers[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange[100],
                                  child: Text(
                                    farmer.name[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  farmer.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: _selectedFarmer?.id == farmer.id
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '${farmer.village} • ${farmer.phoneNumber}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                trailing: _selectedFarmer?.id == farmer.id
                                    ? Icon(Icons.check_circle, color: Colors.orange[800])
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tileColor: _selectedFarmer?.id == farmer.id
                                    ? Colors.orange[50]
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedFarmer = farmer;
                                    _selectedLand = null;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),

            // Selected Farmer Display
            if (_selectedFarmer != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.orange[800], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'निवडलेला शेतकरी: ${_selectedFarmer!.name}',
                            style: GoogleFonts.notoSansDevanagari(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedFarmer!.village} • ${_selectedFarmer!.phoneNumber}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.orange[800]),
                      onPressed: () {
                        setState(() {
                          _selectedFarmer = null;
                          _selectedLand = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLandSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<LandModel>>(
          stream: FirebaseService.getLandsByFarmerId(_selectedFarmer!.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'त्रुटी: ${snapshot.error}',
                  style: GoogleFonts.notoSansDevanagari(color: Colors.red),
                ),
              );
            }

            final allLands = snapshot.data ?? [];

            // Filter lands based on search
            final query = _landSearchController.text.toLowerCase();
            final filteredLands = allLands.where((land) {
              return land.landName.toLowerCase().contains(query) ||
                  land.location.toLowerCase().contains(query) ||
                  land.currentCrop.toLowerCase().contains(query);
            }).toList();

            return Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _landSearchController,
                    decoration: InputDecoration(
                      hintText: 'जमीन शोधा...',
                      hintStyle: GoogleFonts.notoSansDevanagari(fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 16),

                // Lands List
                if (filteredLands.isEmpty)
                  _buildEmptyState('या शेतकऱ्याची जमीन नाही', 'No lands found for this farmer')
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: filteredLands.length,
                      itemBuilder: (context, index) {
                        final land = filteredLands[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.landscape, color: Colors.orange[800], size: 20),
                            ),
                            title: Text(
                              land.landName,
                              style: GoogleFonts.poppins(
                                fontWeight: _selectedLand?.id == land.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              '${land.location} • ${land.currentCrop} • ${land.areaInAcres} एकर',
                              style: GoogleFonts.notoSansDevanagari(fontSize: 12),
                            ),
                            trailing: _selectedLand?.id == land.id
                                ? Icon(Icons.check_circle, color: Colors.orange[800])
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: _selectedLand?.id == land.id
                                ? Colors.orange[50]
                                : null,
                            onTap: () {
                              setState(() => _selectedLand = land);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                if (_selectedLand != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.landscape, color: Colors.orange[800], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'निवडलेली जमीन: ${_selectedLand!.landName}',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedLand!.location} • ${_selectedLand!.currentCrop} • ${_selectedLand!.areaInAcres} एकर',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.orange[800]),
                          onPressed: () {
                            setState(() => _selectedLand = null);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String marathi, String english) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            marathi,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            english,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoseDetails() {
    return Column(
      children: [
        TextFormField(
          controller: _doseNumberController,
          decoration: InputDecoration(
            labelText: 'डोस क्रमांक / Dose Number',
            labelStyle: GoogleFonts.notoSansDevanagari(),
            hintText: 'उदा. 1, 2, 3...',
            prefixIcon: Icon(Icons.numbers, color: Colors.orange[800]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange[800]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'कृपया डोस क्रमांक प्रविष्ट करा';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _selectNextDoseDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.orange[800]),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nextDoseDate == null
                            ? 'पुढील डोसची तारीख निवडा (पर्यायी)'
                            : 'पुढील डोस तारीख',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (_nextDoseDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(_nextDoseDate!),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFertilizersList() {
    if (_fertilizers.isEmpty) {
      return _buildEmptyState('अद्याप खते जोडलेली नाहीत', 'No fertilizers added yet');
    }

    return Column(
      children: _fertilizers.asMap().entries.map((entry) {
        final index = entry.key;
        final fert = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.orange[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.grass, color: Colors.orange[800], size: 20),
            ),
            title: Text(
              fert.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${fert.quantity} ${fert.unit}',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[700]),
              onPressed: () {
                setState(() => _fertilizers.removeAt(index));
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'देयक प्रकार / Payment Type',
                  style: GoogleFonts.notoSansDevanagari(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentOption(
                        'Cash',
                        'रोख',
                        Icons.money,
                        _paymentType == 'Cash',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentOption(
                        'Credit',
                        'उधार',
                        Icons.credit_card,
                        _paymentType == 'Credit',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'रक्कम (₹) / Amount',
            labelStyle: GoogleFonts.notoSansDevanagari(),
            prefixIcon: Icon(Icons.currency_rupee, color: Colors.orange[800]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange[800]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'कृपया रक्कम प्रविष्ट करा';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'टिपणी / Notes (Optional)',
            labelStyle: GoogleFonts.notoSansDevanagari(),
            prefixIcon: Icon(Icons.note, color: Colors.orange[800]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange[800]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _paymentType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.orange[800] : Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.notoSansDevanagari(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.orange[800] : Colors.grey[700],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? Colors.orange[700] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectNextDoseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 15)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[800]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _nextDoseDate = date);
    }
  }

  Future<void> _addFertilizer() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String unit = 'bag';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('खत जोडा / Add Fertilizer', style: GoogleFonts.notoSansDevanagari()),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'खताचे नाव / Fertilizer Name',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'प्रमाण / Quantity',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: unit,
                decoration: InputDecoration(
                  labelText: 'एकक / Unit',
                  labelStyle: GoogleFonts.notoSansDevanagari(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['bag', 'kg', 'gm', 'ltr', 'ml']
                    .map((u) => DropdownMenuItem(
                  value: u,
                  child: Text(u, style: GoogleFonts.poppins()),
                ))
                    .toList(),
                onChanged: (value) => setState(() => unit = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('रद्द करा', style: GoogleFonts.notoSansDevanagari()),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                setState(() {
                  _fertilizers.add(Fertilizer(
                    name: nameController.text,
                    quantity: double.parse(quantityController.text),
                    unit: unit,
                  ));
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
            ),
            child: Text('जोडा', style: GoogleFonts.notoSansDevanagari(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDose() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fertilizers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'कृपया किमान एक खत जोडा',
            style: GoogleFonts.notoSansDevanagari(),
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dose = DoseModel(
        id: '',
        farmerId: _selectedFarmer!.id,
        landId: _selectedLand!.id,
        doseNumber: int.parse(_doseNumberController.text),
        applicationDate: DateTime.now(),
        nextDoseDate: _nextDoseDate,
        fertilizers: _fertilizers,
        paymentType: _paymentType,
        amount: double.parse(_amountController.text),
        isPaid: _paymentType == 'Cash',
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await FirebaseService.addDose(dose);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ डोस यशस्वीरित्या जोडला!',
              style: GoogleFonts.notoSansDevanagari(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ त्रुटी: $e', style: GoogleFonts.notoSansDevanagari()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}