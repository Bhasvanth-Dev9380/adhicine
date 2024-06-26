import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetails {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await _db.collection('users').doc(user.uid).get();
      return doc.data() ?? {};
    }
    return {};
  }
}
