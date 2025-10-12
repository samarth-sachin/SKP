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

  FarmerModel? _selectedFarmer;
  LandModel? _selectedLand;
  String _paymentType = 'Cash';
  DateTime? _nextDoseDate;
  List<Fertilizer> _fertilizers = [];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Dose'),
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
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
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
                      backgroundColor: const Color(0xFF2E7D32),
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
          color: const Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget _buildFarmerSelector() {
    final storageService = Provider.of<LocalStorageService>(context);
    final farmers = storageService.getAllFarmers();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButton<FarmerModel>(
          isExpanded: true,
          hint: const Text('Select a farmer'),
          value: _selectedFarmer,
          underline: const SizedBox(),
          items: farmers.map((farmer) {
            return DropdownMenuItem(
              value: farmer,
              child: Text('${farmer.name} - ${farmer.village}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFarmer = value;
              _selectedLand = null; // Reset land selection
            });
          },
        ),
      ),
    );
  }

  Widget _buildLandSelector() {
    final storageService = Provider.of<LocalStorageService>(context);
    
    return StreamBuilder<List<LandModel>>(
      stream: storageService.getLandsByFarmerId(_selectedFarmer!.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No lands found for this farmer',
                style: GoogleFonts.nunito(color: Colors.grey[600]),
              ),
            ),
          );
        }

        final lands = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButton<LandModel>(
              isExpanded: true,
              hint: const Text('Select land'),
              value: _selectedLand,
              underline: const SizedBox(),
              items: lands.map((land) {
                return DropdownMenuItem(
                  value: land,
                  child: Text('${land.landName} - ${land.currentCrop}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLand = value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoseDetails() {
    return Column(
      children: [
        TextFormField(
          controller: _doseNumberController,
          decoration: const InputDecoration(
            labelText: 'Dose Number',
            prefixIcon: Icon(Icons.numbers),
            border: OutlineInputBorder(),
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
                const Icon(Icons.calendar_today),
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
          child: ListTile(
            leading: const Icon(Icons.grass, color: Color(0xFF2E7D32)),
            title: Text(fert.name),
            subtitle: Text('${fert.quantity} ${fert.unit}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
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
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Cash'),
                        value: 'Cash',
                        groupValue: _paymentType,
                        onChanged: (value) {
                          setState(() => _paymentType = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Credit'),
                        value: 'Credit',
                        groupValue: _paymentType,
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
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
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
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            prefixIcon: Icon(Icons.note),
            border: OutlineInputBorder(),
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
    );

    if (date != null) {
      setState(() => _nextDoseDate = date);
    }
  }

  Future<void> _addFertilizer() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String unit = 'kg';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fertilizer'),
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
                items: ['kg', 'gm', 'ltr', 'ml']
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
            child: const Text('Cancel'),
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDose() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fertilizers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one fertilizer')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageService = Provider.of<LocalStorageService>(context, listen: false);
      
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
          const SnackBar(
            content: Text('Dose added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
    super.dispose();
  }
}
