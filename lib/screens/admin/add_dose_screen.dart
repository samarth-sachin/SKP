import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_service.dart';
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
  List<FarmerModel> _allFarmers = [];
  List<FarmerModel> _filteredFarmers = [];
  List<LandModel> _allLands = [];
  List<LandModel> _filteredLands = [];

  @override
  void initState() {
    super.initState();
    _loadFarmers();
    _farmerSearchController.addListener(_filterFarmers);
    _landSearchController.addListener(_filterLands);
  }

  void _loadFarmers() {
    final storageService = Provider.of<LocalStorageService>(context, listen: false);
    setState(() {
      _allFarmers = storageService.getAllFarmers();
      _filteredFarmers = _allFarmers;
    });
  }

  void _filterFarmers() {
    final query = _farmerSearchController.text.toLowerCase();
    setState(() {
      _filteredFarmers = _allFarmers.where((farmer) {
        return farmer.name.toLowerCase().contains(query) ||
               farmer.village.toLowerCase().contains(query) ||
               farmer.phoneNumber.contains(query);
      }).toList();
    });
  }

  void _filterLands() {
    final query = _landSearchController.text.toLowerCase();
    setState(() {
      _filteredLands = _allLands.where((land) {
        return land.landName.toLowerCase().contains(query) ||
               land.location.toLowerCase().contains(query) ||
               land.currentCrop.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _loadLandsForFarmer(String farmerId) {
    final storageService = Provider.of<LocalStorageService>(context, listen: false);
    final lands = storageService.getLandsByFarmerIdSync(farmerId);
    setState(() {
      _allLands = lands;
      _filteredLands = lands;
      _landSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Dose'),
        backgroundColor: Colors.orange[800], // Admin orange theme
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Select Farmer'),
              _buildFarmerSelector(),
              const SizedBox(height: 24),
              if (_selectedFarmer != null) ...[
                _buildSectionTitle('2. Select Land'),
                _buildLandSelector(),
                const SizedBox(height: 24),
              ],
              if (_selectedLand != null) ...[
                _buildSectionTitle('3. Dose Details'),
                _buildDoseDetails(),
                const SizedBox(height: 24),
                _buildSectionTitle('4. Fertilizers Used'),
                _buildFertilizersList(),
                ElevatedButton.icon(
                  onPressed: _addFertilizer,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Fertilizer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[100],
                    foregroundColor: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('5. Payment Details'),
                _buildPaymentDetails(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitDose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800], // Admin orange theme
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Submit Dose Entry',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange[800], // Admin orange theme
        ),
      ),
    );
  }

  Widget _buildFarmerSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _farmerSearchController,
              decoration: InputDecoration(
                hintText: 'Search farmers by name, village or phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),
            // Farmers List
            if (_filteredFarmers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No farmers found',
                  style: GoogleFonts.nunito(color: Colors.grey[600]),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _filteredFarmers.length,
                  itemBuilder: (context, index) {
                    final farmer = _filteredFarmers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: Icon(Icons.person, color: Colors.orange[800]),
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
                        style: GoogleFonts.nunito(fontSize: 12),
                      ),
                      trailing: _selectedFarmer?.id == farmer.id
                          ? Icon(Icons.check_circle, color: Colors.orange[800])
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedFarmer = farmer;
                          _selectedLand = null;
                          _loadLandsForFarmer(farmer.id);
                        });
                      },
                    );
                  },
                ),
              ),
            if (_selectedFarmer != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.orange[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Farmer: ${_selectedFarmer!.name}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          Text(
                            '${_selectedFarmer!.village} • ${_selectedFarmer!.phoneNumber}',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
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
                          _allLands.clear();
                          _filteredLands.clear();
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
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _landSearchController,
              decoration: InputDecoration(
                hintText: 'Search lands by name, location or crop...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),
            // Lands List
            if (_filteredLands.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No lands found for this farmer',
                  style: GoogleFonts.nunito(color: Colors.grey[600]),
                ),
              )
            else
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _filteredLands.length,
                  itemBuilder: (context, index) {
                    final land = _filteredLands[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.landscape, color: Colors.orange[800]),
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
                        '${land.location} • ${land.currentCrop} • ${land.areaInAcres} acres',
                        style: GoogleFonts.nunito(fontSize: 12),
                      ),
                      trailing: _selectedLand?.id == land.id
                          ? Icon(Icons.check_circle, color: Colors.orange[800])
                          : null,
                      onTap: () {
                        setState(() => _selectedLand = land);
                      },
                    );
                  },
                ),
              ),
            if (_selectedLand != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.landscape, color: Colors.orange[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Land: ${_selectedLand!.landName}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          Text(
                            '${_selectedLand!.location} • ${_selectedLand!.currentCrop}',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
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
        ),
      ),
    );
  }

  Widget _buildDoseDetails() {
    return Column(
      children: [
        TextFormField(
          controller: _doseNumberController,
          decoration: InputDecoration(
            labelText: 'Dose Number',
            prefixIcon: Icon(Icons.numbers, color: Colors.orange[800]),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange[800]!),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter dose number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _selectNextDoseDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.orange[800]),
                const SizedBox(width: 16),
                Text(
                  _nextDoseDate == null
                      ? 'Select next dose date (optional)'
                      : 'Next dose: ${DateFormat('dd MMM yyyy').format(_nextDoseDate!)}',
                  style: GoogleFonts.nunito(),
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
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No fertilizers added yet',
              style: GoogleFonts.nunito(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Column(
      children: _fertilizers.asMap().entries.map((entry) {
        final index = entry.key;
        final fert = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.orange[50],
          child: ListTile(
            leading: Icon(Icons.grass, color: Colors.orange[800]),
            title: Text(fert.name),
            subtitle: Text('${fert.quantity} ${fert.unit}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.orange[800]),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Payment Type',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Cash', style: GoogleFonts.nunito()),
                        value: 'Cash',
                        groupValue: _paymentType,
                        activeColor: Colors.orange[800],
                        onChanged: (value) {
                          setState(() => _paymentType = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Credit', style: GoogleFonts.nunito()),
                        value: 'Credit',
                        groupValue: _paymentType,
                        activeColor: Colors.orange[800],
                        onChanged: (value) {
                          setState(() => _paymentType = value!);
                        },
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
            labelText: 'Amount (₹)',
            prefixIcon: Icon(Icons.currency_rupee, color: Colors.orange[800]),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange[800]!),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            prefixIcon: Icon(Icons.note, color: Colors.orange[800]),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange[800]!),
            ),
          ),
          maxLines: 3,
        ),
      ],
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
  String unit = 'bag'; // Changed default to 'bag'

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add Fertilizer', style: GoogleFonts.poppins()),
      backgroundColor: Colors.orange[50],
      content: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Fertilizer Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: unit,
              decoration: const InputDecoration(labelText: 'Unit'),
              items: ['bag', 'kg', 'gm', 'ltr', 'ml'] // Added 'bag' as first option
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (value) => setDialogState(() => unit = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.nunito()),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                quantityController.text.isNotEmpty) {
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
          child: Text('Add', style: GoogleFonts.nunito(color: Colors.white)),
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
          content: const Text('Please add at least one fertilizer'),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageService = Provider.of<LocalStorageService>(context, listen: false);
      
      final dose = DoseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmerId: _selectedFarmer!.id,
        landId: _selectedLand!.id,
        doseNumber: int.parse(_doseNumberController.text),
        applicationDate: DateTime.now(),
        nextDoseDate: _nextDoseDate,
        fertilizers: _fertilizers,
        paymentType: _paymentType,
        amount: double.parse(_amountController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await storageService.addDose(dose);

      // Send notification
      if (_nextDoseDate != null) {
        await NotificationService().scheduleNotification(
          title: 'Next Dose Reminder',
          body: 'Fertilizer dose scheduled for ${_selectedLand!.landName}',
          scheduledDate: _nextDoseDate!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dose added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _doseNumberController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _farmerSearchController.dispose();
    _landSearchController.dispose();
    super.dispose();
  }
}