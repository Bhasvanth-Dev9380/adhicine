import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentReference> addMedicine(
      String name,
      int compartment,
      Color color,
      String type,
      double quantity,
      int totalCount,
      String startDate,
      String endDate,
      String frequency,
      String times,
      List<Timestamp> doseTimes,
      List<String> foodTimings,
      ) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc = _db.collection('users').doc(user.uid);
      CollectionReference medicineCollection = userDoc.collection('medicines');

      return await medicineCollection.add({
        'name': name,
        'compartment': compartment,
        'color': color.value,
        'type': type,
        'quantity': quantity,
        'totalCount': totalCount,
        'startDate': startDate,
        'endDate': endDate,
        'frequency': frequency,
        'times': times,
        'doseTimes': doseTimes,
        'foodTimings': foodTimings,
      });
    } else {
      throw Exception("User is not logged in");
    }
  }
}
