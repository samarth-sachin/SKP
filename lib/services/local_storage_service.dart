import 'package:flutter/foundation.dart';
import '../models/farmer_model.dart';
import '../models/land_model.dart';
import '../models/dose_model.dart';
import 'firebase_service.dart';

class LocalStorageService extends ChangeNotifier {
  // ✅ Using Firebase - no more mock data

  // ===== FARMER OPERATIONS =====

  Future<String> addFarmer(FarmerModel farmer) async {
    final farmerId = await FirebaseService.registerFarmer(farmer);
    notifyListeners();
    return farmerId;
  }

  Stream<List<FarmerModel>> getAllFarmersStream() {
    return FirebaseService.getAllFarmers();
  }

  Future<FarmerModel?> getFarmerById(String farmerId) async {
    return await FirebaseService.getFarmerById(farmerId);
  }

  // ===== LAND OPERATIONS =====

  Future<String> addLand(LandModel land) async {
    final landId = await FirebaseService.addLand(land);
    notifyListeners();
    return landId;
  }

  Stream<List<LandModel>> getLandsByFarmerId(String farmerId) {
    return FirebaseService.getLandsByFarmerId(farmerId);
  }

  // Synchronous version for quick access
  List<LandModel> getLandsByFarmerIdSync(String farmerId) {
    // For synchronous access, you'll need to use StreamBuilder or FutureBuilder
    // This is just a placeholder - use Stream version in UI
    return [];
  }

  // ===== DOSE OPERATIONS =====

  Future<String> addDose(DoseModel dose) async {
    final doseId = await FirebaseService.addDose(dose);
    notifyListeners();
    return doseId;
  }

  Stream<List<DoseModel>> getDosesForFarmer(String farmerId) {
    return FirebaseService.getDosesForFarmer(farmerId);
  }

  // ===== ANALYTICS =====

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      // Get real-time analytics from Firebase
      final farmers = await FirebaseService.getAllFarmers().first;
      final doses = await FirebaseService.getAllDoses();

      double totalCredit = 0;
      double totalCash = 0;

      for (var dose in doses) {
        if (dose.paymentType == 'Credit') {
          totalCredit += dose.amount;
        } else {
          totalCash += dose.amount;
        }
      }

      return {
        'totalFarmers': farmers.length,
        'totalDoses': doses.length,
        'totalCredit': totalCredit,
        'totalCash': totalCash,
      };
    } catch (e) {
      print('❌ Error getting analytics: $e');
      return {
        'totalFarmers': 0,
        'totalDoses': 0,
        'totalCredit': 0.0,
        'totalCash': 0.0,
      };
    }
  }
}
