import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farmer_model.dart';
import '../models/land_model.dart';
import '../models/dose_model.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get farmersCollection => _firestore.collection('farmers');
  CollectionReference get landsCollection => _firestore.collection('lands');
  CollectionReference get dosesCollection => _firestore.collection('doses');

  // Add Farmer
  Future<String> addFarmer(FarmerModel farmer) async {
    try {
      final docRef = await farmersCollection.add(farmer.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding farmer: $e');
    }
  }

  // Get Farmer by ID
  Future<FarmerModel?> getFarmerById(String farmerId) async {
    try {
      final doc = await farmersCollection.doc(farmerId).get();
      if (doc.exists) {
        return FarmerModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching farmer: $e');
    }
  }

  // Search Farmers
  Stream<List<FarmerModel>> searchFarmers(String query) {
    return farmersCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmerModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Add Land
  Future<String> addLand(LandModel land) async {
    try {
      final docRef = await landsCollection.add(land.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding land: $e');
    }
  }

  // Get Lands by Farmer ID
  Stream<List<LandModel>> getLandsByFarmerId(String farmerId) {
    return landsCollection
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LandModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Add Dose
  Future<String> addDose(DoseModel dose) async {
    try {
      final docRef = await dosesCollection.add(dose.toJson());
      
      // Update land's dose history
      await landsCollection.doc(dose.landId).update({
        'doseHistory': FieldValue.arrayUnion([docRef.id])
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding dose: $e');
    }
  }

  // Get Latest Dose for Land
  Future<DoseModel?> getLatestDoseForLand(String landId) async {
    try {
      final snapshot = await dosesCollection
          .where('landId', isEqualTo: landId)
          .orderBy('applicationDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return DoseModel.fromJson({
          ...snapshot.docs.first.data() as Map<String, dynamic>,
          'id': snapshot.docs.first.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching latest dose: $e');
    }
  }

  // Get All Doses for Land
  Stream<List<DoseModel>> getDosesForLand(String landId) {
    return dosesCollection
        .where('landId', isEqualTo: landId)
        .orderBy('applicationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoseModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Get Analytics Data
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final farmersSnapshot = await farmersCollection.get();
      final dosesSnapshot = await dosesCollection.get();
      
      double totalCredit = 0;
      double totalCash = 0;
      Map<String, int> cropCounts = {};

      for (var doc in dosesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0).toDouble();
        
        if (data['paymentType'] == 'Credit') {
          totalCredit += amount;
        } else {
          totalCash += amount;
        }
      }

      final landsSnapshot = await landsCollection.get();
      for (var doc in landsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final crop = data['currentCrop'] ?? 'Unknown';
        cropCounts[crop] = (cropCounts[crop] ?? 0) + 1;
      }

      return {
        'totalFarmers': farmersSnapshot.docs.length,
        'totalDoses': dosesSnapshot.docs.length,
        'totalCredit': totalCredit,
        'totalCash': totalCash,
        'cropCounts': cropCounts,
      };
    } catch (e) {
      throw Exception('Error fetching analytics: $e');
    }
  }
}
