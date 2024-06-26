import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
    return userDoc.data() as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getAllMedicines() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    QuerySnapshot medicinesSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .get();

    return medicinesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
