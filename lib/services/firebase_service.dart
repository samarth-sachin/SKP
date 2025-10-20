import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/farmer_model.dart';
import '../models/land_model.dart';
import '../models/dose_model.dart';
import '../models/status_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Collections
  static const String _farmersCollection = 'farmers';
  static const String _landsCollection = 'lands';
  static const String _dosesCollection = 'doses';
  static const String _notificationsCollection = 'notifications';

  // ===== FARMER OPERATIONS =====

  /// Register new farmer with all details
  static Future<String> registerFarmer(FarmerModel farmer) async {
    try {
      final docRef = _firestore.collection(_farmersCollection).doc();
      final farmerId = docRef.id;

      // ✅ Try to get FCM token, but don't fail if it doesn't work
      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
        print('✅ FCM Token obtained: $fcmToken');
      } catch (fcmError) {
        print('⚠️ FCM Token unavailable (will add later): $fcmError');
        fcmToken = null; // Continue without FCM token
      }

      final farmerData = {
        'id': farmerId,
        'name': farmer.name,
        'village': farmer.village,
        'phoneNumber': farmer.phoneNumber,
        'alternatePhone': farmer.alternatePhone ?? '',
        'aadhaarNumber': farmer.aadhaarNumber,
        'registrationDate': FieldValue.serverTimestamp(),
        'landIds': [],
        'fcmToken': fcmToken ?? '', // Empty if FCM failed
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(farmerData);
      print('✅ Farmer registered successfully: $farmerId');
      return farmerId;
    } catch (e) {
      print('❌ Error registering farmer: $e');
      rethrow;
    }
  }


  /// Get all farmers (for admin)
  static Stream<List<FarmerModel>> getAllFarmers() {
    return _firestore
        .collection(_farmersCollection)
        .orderBy('registrationDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FarmerModel(
          id: doc.id,
          name: data['name'] ?? '',
          village: data['village'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          alternatePhone: data['alternatePhone'],
          aadhaarNumber: data['aadhaarNumber'],
          registrationDate: (data['registrationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          landIds: List<String>.from(data['landIds'] ?? []),
        );
      }).toList();
    });
  }

  /// Get farmer by ID
  static Future<FarmerModel?> getFarmerById(String farmerId) async {
    try {
      final doc = await _firestore.collection(_farmersCollection).doc(farmerId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return FarmerModel(
        id: doc.id,
        name: data['name'],
        village: data['village'],
        phoneNumber: data['phoneNumber'],
        alternatePhone: data['alternatePhone'],
        aadhaarNumber: data['aadhaarNumber'],
        registrationDate: (data['registrationDate'] as Timestamp).toDate(),
        landIds: List<String>.from(data['landIds'] ?? []),
      );
    } catch (e) {
      print('❌ Error getting farmer: $e');
      return null;
    }}
  static Future<List<LandModel>> getAllLands() async {
    try {
      final snapshot = await _firestore.collection(_landsCollection).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LandModel(
          id: doc.id,
          farmerId: data['farmerId'],
          landName: data['landName'],
          location: data['location'],
          currentCrop: data['currentCrop'],
          areaInAcres: (data['areaInAcres'] as num).toDouble(),
          doseHistory: List<String>.from(data['doseHistory'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting all lands: $e');
      return [];
    }
  }

  /// Search farmers
  static Stream<List<FarmerModel>> searchFarmers(String query) {
    return _firestore
        .collection(_farmersCollection)
        .where('phoneNumber', isEqualTo: query)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FarmerModel(
          id: doc.id,
          name: data['name'],
          village: data['village'],
          phoneNumber: data['phoneNumber'],
          alternatePhone: data['alternatePhone'],
          aadhaarNumber: data['aadhaarNumber'],
          registrationDate: (data['registrationDate'] as Timestamp).toDate(),
          landIds: List<String>.from(data['landIds'] ?? []),
        );
      }).toList();
    });
  }
  /// Delete farmer and all associated data (Admin only)
  static Future<void> deleteFarmer(String farmerId) async {
    try {
      // 1. Get all lands for this farmer
      final landsSnapshot = await _firestore
          .collection(_landsCollection)
          .where('farmerId', isEqualTo: farmerId)
          .get();

      // 2. Delete all doses for each land
      for (var landDoc in landsSnapshot.docs) {
        final landId = landDoc.id;

        // Get all doses for this land
        final dosesSnapshot = await _firestore
            .collection(_dosesCollection)
            .where('landId', isEqualTo: landId)
            .get();

        // Delete all doses
        for (var doseDoc in dosesSnapshot.docs) {
          await doseDoc.reference.delete();
        }

        // Delete the land
        await landDoc.reference.delete();
      }

      // 3. Delete the farmer
      await _firestore.collection(_farmersCollection).doc(farmerId).delete();

      print('✅ Farmer and all data deleted: $farmerId');
    } catch (e) {
      print('❌ Error deleting farmer: $e');
      rethrow;
    }
  }

  // ===== LAND OPERATIONS =====

  /// Add land for farmer
  static Future<String> addLand(LandModel land) async {
    try {
      final docRef = _firestore.collection(_landsCollection).doc();
      final landId = docRef.id;

      final landData = {
        'id': landId,
        'farmerId': land.farmerId,
        'landName': land.landName,
        'location': land.location,
        'currentCrop': land.currentCrop,
        'areaInAcres': land.areaInAcres,
        'doseHistory': [],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(landData);

      // Update farmer's landIds
      await _firestore.collection(_farmersCollection).doc(land.farmerId).update({
        'landIds': FieldValue.arrayUnion([landId]),
      });

      print('✅ Land added: $landId');
      return landId;
    } catch (e) {
      print('❌ Error adding land: $e');
      rethrow;
    }
  }

  /// Get lands by farmer ID
  static Stream<List<LandModel>> getLandsByFarmerId(String farmerId) {
    return _firestore
        .collection(_landsCollection)
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LandModel(
          id: doc.id,
          farmerId: data['farmerId'],
          landName: data['landName'],
          location: data['location'],
          currentCrop: data['currentCrop'],
          areaInAcres: data['areaInAcres'].toDouble(),
          doseHistory: List<String>.from(data['doseHistory'] ?? []),
        );
      }).toList();
    });
  }
  /// Get doses for specific land (shows land-specific dose history)
  static Stream<List<DoseModel>> getDosesForLand(String landId) {
    return _firestore
        .collection(_dosesCollection)
        .where('landId', isEqualTo: landId)
        .orderBy('applicationDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DoseModel(
          id: doc.id,
          farmerId: data['farmerId'],
          landId: data['landId'],
          doseNumber: data['doseNumber'],
          applicationDate: (data['applicationDate'] as Timestamp).toDate(),
          nextDoseDate: data['nextDoseDate'] != null
              ? (data['nextDoseDate'] as Timestamp).toDate()
              : null,
          fertilizers: (data['fertilizers'] as List).map((f) =>
              Fertilizer(
                name: f['name'],
                quantity: (f['quantity'] as num).toDouble(),
                unit: f['unit'],
              )
          ).toList(),
          paymentType: data['paymentType'],
          amount: (data['amount'] as num).toDouble(),
          isPaid: data['isPaid'],
          notes: data['notes'],
        );
      }).toList();
    });
  }

  // ===== DOSE OPERATIONS =====

  /// Add dose (Admin creates dose for farmer)
  static Future<String> addDose(DoseModel dose) async {
    try {
      final docRef = _firestore.collection(_dosesCollection).doc();
      final doseId = docRef.id;

      final doseData = {
        'id': doseId,
        'farmerId': dose.farmerId,
        'landId': dose.landId,
        'doseNumber': dose.doseNumber,
        'applicationDate': Timestamp.fromDate(dose.applicationDate),
        'nextDoseDate': dose.nextDoseDate != null ? Timestamp.fromDate(dose.nextDoseDate!) : null,
        'fertilizers': dose.fertilizers.map((f) => {
          'name': f.name,
          'quantity': f.quantity,
          'unit': f.unit,
        }).toList(),
        'paymentType': dose.paymentType,
        'amount': dose.amount,
        'isPaid': dose.isPaid,
        'notes': dose.notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(doseData);

      // Update land's dose history
      await _firestore.collection(_landsCollection).doc(dose.landId).update({
        'doseHistory': FieldValue.arrayUnion([doseId]),
      });

      // ✅ Send notification to farmer
      await _sendDoseNotification(dose.farmerId, doseId, dose.doseNumber);

      print('✅ Dose added: $doseId');
      return doseId;
    } catch (e) {
      print('❌ Error adding dose: $e');
      rethrow;
    }
  }

  /// Get doses for farmer
  static Stream<List<DoseModel>> getDosesForFarmer(String farmerId) {
    return _firestore
        .collection(_dosesCollection)
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('applicationDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DoseModel(
          id: doc.id,
          farmerId: data['farmerId'],
          landId: data['landId'],
          doseNumber: data['doseNumber'],
          applicationDate: (data['applicationDate'] as Timestamp).toDate(),
          nextDoseDate: data['nextDoseDate'] != null
              ? (data['nextDoseDate'] as Timestamp).toDate()
              : null,
          fertilizers: (data['fertilizers'] as List).map((f) =>
              Fertilizer(
                name: f['name'],
                quantity: (f['quantity'] as num).toDouble(),
                unit: f['unit'],
              )
          ).toList(),
          paymentType: data['paymentType'],
          amount: (data['amount'] as num).toDouble(),
          isPaid: data['isPaid'],
          notes: data['notes'],
        );
      }).toList();
    });
  }

  // ===== NOTIFICATIONS =====

  /// Send dose notification to farmer
  static Future<void> _sendDoseNotification(String farmerId, String doseId, int doseNumber) async {
    try {
      final notificationData = {
        'farmerId': farmerId,
        'type': 'dose',
        'title': 'नवीन डोस जोडला',
        'titleEnglish': 'New Dose Added',
        'message': 'प्रशासकाने डोस क्रमांक $doseNumber जोडला आहे',
        'messageEnglish': 'Admin has added dose number $doseNumber',
        'doseId': doseId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_notificationsCollection).add(notificationData);
      print('✅ Notification sent to farmer: $farmerId');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Get notifications for farmer
  static Stream<List<Map<String, dynamic>>> getNotificationsForFarmer(String farmerId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('farmerId', isEqualTo: farmerId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection(_notificationsCollection).doc(notificationId).update({
      'isRead': true,
    });
  }

  // ===== ANALYTICS =====

  /// Get analytics data
  static Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final farmersSnapshot = await _firestore.collection(_farmersCollection).get();
      final dosesSnapshot = await _firestore.collection(_dosesCollection).get();

      double totalCredit = 0;
      double totalCash = 0;

      for (var doc in dosesSnapshot.docs) {
        final data = doc.data();
        if (data['paymentType'] == 'Credit') {
          totalCredit += (data['amount'] as num).toDouble();
        } else {
          totalCash += (data['amount'] as num).toDouble();
        }
      }

      return {
        'totalFarmers': farmersSnapshot.docs.length,
        'totalDoses': dosesSnapshot.docs.length,
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

// Add these methods to FirebaseService class

  /// Get all doses (for analytics)
  static Future<List<DoseModel>> getAllDoses() async {
    try {
      final snapshot = await _firestore.collection(_dosesCollection).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DoseModel(
          id: doc.id,
          farmerId: data['farmerId'],
          landId: data['landId'],
          doseNumber: data['doseNumber'],
          applicationDate: (data['applicationDate'] as Timestamp).toDate(),
          nextDoseDate: data['nextDoseDate'] != null
              ? (data['nextDoseDate'] as Timestamp).toDate()
              : null,
          fertilizers: (data['fertilizers'] as List).map((f) =>
              Fertilizer(
                name: f['name'],
                quantity: (f['quantity'] as num).toDouble(),
                unit: f['unit'],
              )
          ).toList(),
          paymentType: data['paymentType'],
          amount: (data['amount'] as num).toDouble(),
          isPaid: data['isPaid'],
          notes: data['notes'],
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting all doses: $e');
      return [];
    }
  }
  /// Check if farmer exists by Aadhaar number
  static Future<FarmerModel?> getFarmerByAadhaar(String aadhaarNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_farmersCollection)
          .where('aadhaarNumber', isEqualTo: aadhaarNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      return FarmerModel(
        id: doc.id,
        name: data['name'],
        village: data['village'],
        phoneNumber: data['phoneNumber'],
        alternatePhone: data['alternatePhone'],
        aadhaarNumber: data['aadhaarNumber'],
        registrationDate: (data['registrationDate'] as Timestamp).toDate(),
        landIds: List<String>.from(data['landIds'] ?? []),
      );
    } catch (e) {
      print('❌ Error checking Aadhaar: $e');
      return null;
    }
  }
// ===== 5️⃣ STATUS UPDATES OPERATIONS =====

  static const String _statusCollection = 'status_updates';

  /// Upload image/video to Firebase Storage
  static Future<String> uploadStatusMedia(File file, String statusId, bool isVideo) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('status_updates')
          .child(statusId)
          .child(isVideo ? 'video.mp4' : 'image.jpg');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Media uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading media: $e');
      rethrow;
    }
  }

  /// Add new status
  static Future<String> addStatus(StatusModel status, {File? mediaFile}) async {
    try {
      final docRef = _firestore.collection(_statusCollection).doc();
      final statusId = docRef.id;

      String? mediaUrl;

      // Upload media if provided
      if (mediaFile != null) {
        final isVideo = status.type == StatusType.video;
        mediaUrl = await uploadStatusMedia(mediaFile, statusId, isVideo);
      }

      final statusData = status.copyWith().toFirestore();
      statusData['id'] = statusId;
      statusData['imageUrl'] = mediaUrl;

      await docRef.set(statusData);

      print('✅ Status added: $statusId');
      return statusId;
    } catch (e) {
      print('❌ Error adding status: $e');
      rethrow;
    }
  }

  /// Get all active statuses (not expired)
  static Stream<List<StatusModel>> getActiveStatuses() {
    return _firestore
        .collection(_statusCollection)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StatusModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get all statuses for admin (including expired)
  static Stream<List<StatusModel>> getAllStatusesForAdmin() {
    return _firestore
        .collection(_statusCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StatusModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update status
  static Future<void> updateStatus(StatusModel status, {File? newMediaFile}) async {
    try {
      String? mediaUrl = status.imageUrl;

      // Upload new media if provided
      if (newMediaFile != null) {
        final isVideo = status.type == StatusType.video;
        mediaUrl = await uploadStatusMedia(newMediaFile, status.id, isVideo);
      }

      final statusData = status.toFirestore();
      statusData['imageUrl'] = mediaUrl;

      await _firestore.collection(_statusCollection).doc(status.id).update(statusData);

      print('✅ Status updated: ${status.id}');
    } catch (e) {
      print('❌ Error updating status: $e');
      rethrow;
    }
  }

  /// Delete status
  static Future<void> deleteStatus(String statusId) async {
    try {
      // Delete media from storage
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('status_updates')
            .child(statusId);
        await storageRef.delete();
      } catch (e) {
        print('⚠️ No media to delete or error: $e');
      }

      // Delete from Firestore
      await _firestore.collection(_statusCollection).doc(statusId).delete();

      print('✅ Status deleted: $statusId');
    } catch (e) {
      print('❌ Error deleting status: $e');
      rethrow;
    }
  }

  /// Increment view count
  static Future<void> incrementStatusViewCount(String statusId) async {
    try {
      await _firestore.collection(_statusCollection).doc(statusId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ Error incrementing view count: $e');
    }
  }

  /// Delete expired statuses (call this periodically)
  static Future<void> deleteExpiredStatuses() async {
    try {
      final expiredSnapshot = await _firestore
          .collection(_statusCollection)
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      for (var doc in expiredSnapshot.docs) {
        await deleteStatus(doc.id);
      }

      print('✅ Deleted ${expiredSnapshot.docs.length} expired statuses');
    } catch (e) {
      print('❌ Error deleting expired statuses: $e');
    }
  }

  }


