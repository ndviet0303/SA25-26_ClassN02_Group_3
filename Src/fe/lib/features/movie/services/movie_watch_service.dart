import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieWatchService {
  MovieWatchService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<bool> hasAccess(String movieId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final movieDoc = await _db.collection('movies').doc(movieId).get();
      final data = movieDoc.data() ?? {};
      final price = (data['price'] ?? {}) as Map<String, dynamic>;
      final priceUsd = (price['usd'] as num?)?.toDouble() ?? 0.0;
      if (priceUsd <= 0) return true;

      final purchasedDoc = await _db
          .collection('users')
          .doc(user.uid)
          .collection('purchases')
          .doc(movieId)
          .get();
      if (purchasedDoc.exists) return true;

      final userDoc = await _db.collection('users').doc(user.uid).get();
      final isSubscribed = (userDoc.data() ?? {})['isSubscribed'] == true;
      if (isSubscribed) return true;
    } catch (_) {}
    return false;
  }

  Future<void> incrementView(String movieId) async {
    try {
      await _db.collection('movies').doc(movieId).update({
        'view': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  Future<void> addWatchHistory(String movieId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final historyRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('watch_history')
          .doc(movieId);
      await historyRef.set({
        'movieId': movieId,
        'lastWatchedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}


