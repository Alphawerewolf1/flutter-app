import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a user profile using an atomic transaction that
  /// increments a 'counters/users' document for a monotonic ID.
  /// This avoids collection-wide queries which are blocked by strict rules.
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String username,
    required String email,
  }) async {
    // Sanity check
    if (uid.isEmpty) {
      throw Exception("Provided uid is empty.");
    }

    final DocumentReference counterRef =
    _firestore.collection('counters').doc('users');

    final DocumentReference userRef = _firestore.collection('users').doc(uid);

    // Run a transaction to atomically increment the counter and create the user doc.
    await _firestore.runTransaction((transaction) async {
      final counterSnap = await transaction.get(counterRef);

      int nextId = 1;
      if (counterSnap.exists) {
        final data = counterSnap.data() as Map<String, dynamic>;
        final last = (data['last'] is int) ? data['last'] as int : 0;
        nextId = last + 1;
        // update counter
        transaction.update(counterRef, {'last': nextId});
      } else {
        // initialize counter
        transaction.set(counterRef, {'last': nextId});
      }

      // Prepare user document data
      final userData = {
        'id': nextId,
        'name': name.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Create the user document under users/{uid}
      transaction.set(userRef, userData);
    });
  }
}
