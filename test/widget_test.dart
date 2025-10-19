// Add this to test Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

void testFirebase() async {
  try {
    // Test write
    await FirebaseFirestore.instance.collection('test').add({
      'message': 'Hello Firebase!',
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('✅ Firebase connected successfully!');
  } catch (e) {
    print('❌ Firebase error: $e');
  }
}
