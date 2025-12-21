import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingsService {
  RatingsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> submitReview({
    required String movieId,
    required int rating,
    String? comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not logged in');
    }

    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }

    final ratingDocRef = _firestore.collection('ratings').doc(movieId);
    final reviewDocRef = ratingDocRef.collection('reviews').doc(user.uid);

    // Resolve display name / avatar from preferences or Firestore user doc, with auth fallback
    final resolved = await _resolveUserProfile(user);
    final resolvedName = resolved['name'];
    final resolvedAvatar = resolved['avatar'];

    await _firestore.runTransaction((txn) async {
      final now = FieldValue.serverTimestamp();

      final ratingSnap = await txn.get(ratingDocRef);
      int total = 0;
      int sum = 0;
      Map<String, int> starsCount = _initStarsCount();

      if (ratingSnap.exists) {
        final data = ratingSnap.data() as Map<String, dynamic>;
        total = (data['totalReviews'] as num?)?.toInt() ?? 0;
        sum = (data['sumRatings'] as num?)?.toInt() ?? 0;
        starsCount = _initStarsCount(data['starsCount'] as Map?);
      }

      final existingReviewSnap = await txn.get(reviewDocRef);
      int? oldRating;

      if (existingReviewSnap.exists) {
        final existing = existingReviewSnap.data() as Map<String, dynamic>;
        oldRating = (existing['rating'] as num?)?.toInt() ?? 0;
        sum = sum - oldRating + rating;
        if (oldRating >= 1 && oldRating <= 5) {
          starsCount[oldRating.toString()] = (starsCount[oldRating.toString()] ?? 1) - 1;
        }
        starsCount[rating.toString()] = (starsCount[rating.toString()] ?? 0) + 1;
        txn.update(reviewDocRef, {
          'userId': user.uid,
          'rating': rating,
          'comment': comment ?? existing['comment'],
          'userName': resolvedName ?? existing['userName'],
          'userAvatar': resolvedAvatar ?? existing['userAvatar'],
          'updatedAt': now,
          'createdAt': existing['createdAt'] ?? now,
        });
      } else {
        total += 1;
        sum += rating;
        starsCount[rating.toString()] = (starsCount[rating.toString()] ?? 0) + 1;
        txn.set(reviewDocRef, {
          'userId': user.uid,
          'rating': rating,
          'comment': comment,
          'userName': resolvedName ?? user.displayName ?? user.email ?? user.uid,
          'userAvatar': resolvedAvatar ?? user.photoURL ?? '',
          'likes': 0,
          'likedBy': <String>[],
          'createdAt': now,
          'updatedAt': now,
        });
      }

      final average = total == 0 ? 0.0 : (sum / total);
      final aggregatePayload = _buildAggregatePayload(
        averageRating: average,
        totalReviews: total,
        sumRatings: sum,
        starsCount: starsCount,
        updatedAt: now,
      );
      if (ratingSnap.exists) {
        txn.update(ratingDocRef, {
          ...aggregatePayload,
          // remove legacy/duplicate fields
          'totalReview': FieldValue.delete(),
          'totalRating': FieldValue.delete(),
          'sumRating': FieldValue.delete(),
        });
      } else {
        txn.set(ratingDocRef, {
          ...aggregatePayload,
          'createdAt': now,
        });
      }

      // Sync aggregates to movies collection (tmdb fields)
      final moviesDocRef = _firestore.collection('movies').doc(movieId);
      final voteAverage = (average * 2).clamp(0.0, 10.0);
      txn.update(moviesDocRef, {
        'tmdb.vote_average': voteAverage,
        'tmdb.vote_count': total,
      });
    });
  }

  Future<Map<String, String?>> _resolveUserProfile(User user) async {
    String? name;
    String? avatar;

    // 1) Prefer Firestore profile by userId (contains photoUrl most reliably)
    try {
      final snap = await _firestore.collection('users').doc(user.uid).get();
      final data = snap.data();
      if (data != null) {
        name = (data['displayName'] as String?) ?? (data['name'] as String?);
        avatar = (data['photoUrl'] as String?) ?? (data['photoURL'] as String?) ?? (data['avatarUrl'] as String?);
      }
    } catch (_) {}

    // 2) Fallback to SharedPreferences cache
    if ((name == null || name.isEmpty) || (avatar == null || avatar.isEmpty)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        name = name ?? prefs.getString('userName') ?? prefs.getString('profile.displayName');
        avatar = avatar ?? prefs.getString('userAvatar') ?? prefs.getString('profile.photoURL') ?? prefs.getString('profile.photoUrl');
      } catch (_) {}
    }

    // 3) Final fallback to FirebaseAuth provider
    name = name ?? user.displayName ?? user.email ?? user.uid;
    if (avatar == null || avatar.isEmpty) {
      final providerPhoto = user.providerData.isNotEmpty ? user.providerData.first.photoURL : null;
      avatar = user.photoURL ?? providerPhoto ?? '';
    }

    return {'name': name, 'avatar': avatar};
  }

  Future<void> toggleLike({
    required String movieId,
    required String reviewUserId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not logged in');
    }
    final reviewDocRef = _firestore
        .collection('ratings')
        .doc(movieId)
        .collection('reviews')
        .doc(reviewUserId);

    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(reviewDocRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final likedBy = List<String>.from((data['likedBy'] as List?) ?? const []);
      final hasLiked = likedBy.contains(user.uid);
      if (hasLiked) {
        likedBy.remove(user.uid);
      } else {
        likedBy.add(user.uid);
      }
      txn.update(reviewDocRef, {
        'likedBy': likedBy,
        'likes': likedBy.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Map<String, int> _initStarsCount([Map? existing]) {
    final base = { '1': 0, '2': 0, '3': 0, '4': 0, '5': 0 };
    if (existing == null) return base;
    final casted = existing.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    for (final k in base.keys) {
      base[k] = casted[k] ?? 0;
    }
    return base;
  }

  Map<String, dynamic> _buildAggregatePayload({
    required double averageRating,
    required int totalReviews,
    required int sumRatings,
    required Map<String, int> starsCount,
    required FieldValue updatedAt,
  }) {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'sumRatings': sumRatings,
      'starsCount': starsCount,
      'updatedAt': updatedAt,
    };
  }
}


