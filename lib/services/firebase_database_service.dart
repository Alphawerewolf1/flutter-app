import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  static final _db = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL:
    "https://personal-app-6c704-default-rtdb.asia-southeast1.firebasedatabase.app/",
  ).ref();

  final _auth = FirebaseAuth.instance;

  DatabaseReference getUserNotesRef() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return _db.child('notes').child(user.uid);
  }

  Future<void> addNote(String title, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = _db.child('notes').child(user.uid).push();
    await ref.set({
      'title': title,
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateNote(String id, String title, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.child('notes').child(user.uid).child(id).update({
      'title': title,
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteNote(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.child('notes').child(user.uid).child(id).remove();
  }

  // ---------------------
  // Coin flip helpers
  // ---------------------

  /// Adds a flip entry and trims to last [maxKeep] entries (default 5).
  Future<void> addFlip(String result, {int maxKeep = 5}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final flipsRef = _db.child('coin_flips').child(user.uid);
    final pushRef = flipsRef.push();
    final timestamp = DateTime.now().toIso8601String();

    await pushRef.set({
      'result': result,
      'timestamp': timestamp,
    });

    // Trim older items if we have more than maxKeep
    final snapshot = await flipsRef.orderByChild('timestamp').get();
    final children = snapshot.children.toList();
    final count = children.length;
    if (count > maxKeep) {
      final toDelete = count - maxKeep;
      // children are ordered ascending by timestamp (oldest first)
      for (int i = 0; i < toDelete; i++) {
        final oldKey = children[i].key;
        if (oldKey != null) {
          await flipsRef.child(oldKey).remove();
        }
      }
    }
  }

  /// Returns the most recent [limit] flips (newest first).
  /// Each map: {'result': ..., 'timestamp': ...}
  Future<List<Map<String, String>>> getLatestFlips({int limit = 5}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final flipsRef = _db.child('coin_flips').child(user.uid);
    final snapshot = await flipsRef.orderByChild('timestamp').limitToLast(limit).get();

    if (!snapshot.exists) return [];

    final list = snapshot.children
        .map((child) {
      final val = child.value as Map<dynamic, dynamic>?;
      if (val == null) return null;
      return <String, String>{
        'result': val['result']?.toString() ?? '',
        'timestamp': val['timestamp']?.toString() ?? '',
      };
    })
        .where((e) => e != null)
        .cast<Map<String, String>>()
        .toList();

    // snapshot.limitToLast returns in ascending order (oldest->newest by timestamp),
    // so reverse to return newest first.
    return list.reversed.toList();
  }
}
