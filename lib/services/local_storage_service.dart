import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/farmer_model.dart';
import '../models/land_model.dart';
import '../models/dose_model.dart';

class LocalStorageService extends ChangeNotifier {
  // Mock data storage
  List<FarmerModel> _farmers = [];
  List<LandModel> _lands = [];
  List<DoseModel> _doses = [];

  LocalStorageService() {
    _loadMockData();
  }

  // Load mock data for testing
  void _loadMockData() {
    // Add some demo farmers
    _farmers = [
      FarmerModel(
        id: '1',
        name: 'Ramesh Patil',
        village: 'Pune',
        phoneNumber: '9876543210',
        registrationDate: DateTime.now().subtract(const Duration(days: 30)),
        landIds: ['1', '2'],
      ),
      FarmerModel(
        id: '2',
        name: 'Suresh Kumar',
        village: 'Mumbai',
        phoneNumber: '9876543211',
        registrationDate: DateTime.now().subtract(const Duration(days: 20)),
        landIds: ['3'],
      ),
    ];

    // Add some demo lands
    _lands = [
      LandModel(
        id: '1',
        farmerId: '1',
        landName: 'East Field',
        location: 'Near River',
        currentCrop: 'Wheat',
        areaInAcres: 5.0,
        doseHistory: ['1'],
      ),
      LandModel(
        id: '2',
        farmerId: '1',
        landName: 'West Field',
        location: 'Main Road',
        currentCrop: 'Rice',
        areaInAcres: 3.0,
        doseHistory: ['2'],
      ),
      LandModel(
        id: '3',
        farmerId: '2',
        landName: 'North Field',
        location: 'Hill Side',
        currentCrop: 'Cotton',
        areaInAcres: 4.0,
        doseHistory: [],
      ),
    ];

    // Add some demo doses
    _doses = [
      DoseModel(
        id: '1',
        farmerId: '1',
        landId: '1',
        doseNumber: 1,
        applicationDate: DateTime.now().subtract(const Duration(days: 15)),
        nextDoseDate: DateTime.now().add(const Duration(days: 15)),
        fertilizers: [
          Fertilizer(name: 'Urea', quantity: 2.0, unit: 'kg'),
          Fertilizer(name: 'DAP', quantity: 1.5, unit: 'kg'),
        ],
        paymentType: 'Credit',
        amount: 2500.0,
        isPaid: false,
        notes: 'Apply after watering',
      ),
      DoseModel(
        id: '2',
        farmerId: '1',
        landId: '2',
        doseNumber: 1,
        applicationDate: DateTime.now().subtract(const Duration(days: 10)),
        nextDoseDate: DateTime.now().add(const Duration(days: 20)),
        fertilizers: [
          Fertilizer(name: 'NPK', quantity: 3.0, unit: 'kg'),
        ],
        paymentType: 'Cash',
        amount: 1800.0,
        isPaid: true,
        notes: 'Good weather for application',
      ),
    ];
  }

  // Add Farmer
  Future<String> addFarmer(FarmerModel farmer) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newFarmer = FarmerModel(
      id: newId,
      name: farmer.name,
      village: farmer.village,
      phoneNumber: farmer.phoneNumber,
      alternatePhone: farmer.alternatePhone,
      registrationDate: farmer.registrationDate,
      landIds: farmer.landIds,
    );
    _farmers.add(newFarmer);
    notifyListeners();
    return newId;
  }

  // Get Farmer by ID
  Future<FarmerModel?> getFarmerById(String farmerId) async {
    try {
      return _farmers.firstWhere((f) => f.id == farmerId);
    } catch (e) {
      return null;
    }
  }

  // Search Farmers
  Stream<List<FarmerModel>> searchFarmers(String query) {
    return Stream.value(
      _farmers.where((f) => 
        f.name.toLowerCase().contains(query.toLowerCase()) ||
        f.village.toLowerCase().contains(query.toLowerCase()) ||
        f.phoneNumber.contains(query)
      ).toList()
    );
  }

  // Add Land
  Future<String> addLand(LandModel land) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newLand = LandModel(
      id: newId,
      farmerId: land.farmerId,
      landName: land.landName,
      location: land.location,
      currentCrop: land.currentCrop,
      areaInAcres: land.areaInAcres,
      doseHistory: land.doseHistory,
    );
    _lands.add(newLand);
    notifyListeners();
    return newId;
  }

  // Get Lands by Farmer ID
  Stream<List<LandModel>> getLandsByFarmerId(String farmerId) {
    return Stream.value(
      _lands.where((l) => l.farmerId == farmerId).toList()
    );
  }

  // Add Dose
  Future<String> addDose(DoseModel dose) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newDose = DoseModel(
      id: newId,
      farmerId: dose.farmerId,
      landId: dose.landId,
      doseNumber: dose.doseNumber,
      applicationDate: dose.applicationDate,
      nextDoseDate: dose.nextDoseDate,
      fertilizers: dose.fertilizers,
      paymentType: dose.paymentType,
      amount: dose.amount,
      isPaid: dose.isPaid,
      notes: dose.notes,
    );
    _doses.add(newDose);
    
    // Update land's dose history
    final landIndex = _lands.indexWhere((l) => l.id == dose.landId);
    if (landIndex != -1) {
      _lands[landIndex].doseHistory.add(newId);
    }
    
    notifyListeners();
    return newId;
  }

  // Get Latest Dose for Land
  Future<DoseModel?> getLatestDoseForLand(String landId) async {
    try {
      final landDoses = _doses.where((d) => d.landId == landId).toList();
      if (landDoses.isEmpty) return null;
      
      landDoses.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
      return landDoses.first;
    } catch (e) {
      return null;
    }
  }

  // Get All Doses for Land
  Stream<List<DoseModel>> getDosesForLand(String landId) {
    final landDoses = _doses.where((d) => d.landId == landId).toList();
    landDoses.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
    return Stream.value(landDoses);
  }

  // Get Analytics Data
  Future<Map<String, dynamic>> getAnalytics() async {
    double totalCredit = 0;
    double totalCash = 0;
    Map<String, int> cropCounts = {};

    for (var dose in _doses) {
      if (dose.paymentType == 'Credit') {
        totalCredit += dose.amount;
      } else {
        totalCash += dose.amount;
      }
    }

    for (var land in _lands) {
      cropCounts[land.currentCrop] = (cropCounts[land.currentCrop] ?? 0) + 1;
    }

    return {
      'totalFarmers': _farmers.length,
      'totalDoses': _doses.length,
      'totalCredit': totalCredit,
      'totalCash': totalCash,
      'cropCounts': cropCounts,
    };
  }

  // Get all farmers (for admin)
  List<FarmerModel> getAllFarmers() => _farmers;

  // Get all lands (for admin)
  List<LandModel> getAllLands() => _lands;

  // Get all doses (for admin)
  List<DoseModel> getAllDoses() => _doses;
}
