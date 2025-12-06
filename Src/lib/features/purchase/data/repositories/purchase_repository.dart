import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/repositories/movie_repository.dart';
import '../../models/purchase_item.dart';
import '../../models/transaction_item.dart';
import '../../../notification/models/notification_item.dart';
import '../../../notification/repositories/notification_repository.dart';
import '../../../../i18n/translations.g.dart';
import '../../../notification/providers/notification_providers.dart';

final purchaseRepositoryProvider = Provider((ref) => PurchaseRepository(
  ref.watch(firestoreProvider),
  FirebaseAuth.instance,
  ref.watch(notificationRepositoryProvider),
));

class PurchaseRepository {
  PurchaseRepository(this._db, this._auth, this._notificationRepo);
  
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final NotificationRepository _notificationRepo;

  String? get _userId => _auth.currentUser?.uid;

  /// Stream purchased items cho user hiện tại
  Stream<List<PurchaseItem>> streamPurchases() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return <PurchaseItem>[];

      // Fetch movie details từ movies collection
      final purchases = <PurchaseItem>[];
      
      // Tạo map để truy cập nhanh purchase data
      final purchaseDataMap = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        purchaseDataMap[doc.id] = doc.data();
      }

      // Fetch tất cả movies cùng lúc
      final movieIds = purchaseDataMap.keys.toList();
      
      for (final movieId in movieIds) {
        try {
          final movieDoc = await _db.collection('movies').doc(movieId).get();
          if (movieDoc.exists) {
            final movie = Movie.fromDoc(movieDoc);
            final movieItem = MovieItem.fromMovie(movie);
            final purchaseData = purchaseDataMap[movieId] ?? {};
            
            purchases.add(PurchaseItem(
              id: movieItem.id,
              title: movieItem.title,
              imageUrl: movieItem.imageUrl,
              rating: movieItem.rating,
              price: movieItem.price,
              isDownloaded: purchaseData['isDownloaded'] as bool? ?? true,
              isFinished: purchaseData['isFinished'] as bool? ?? false,
            ));
          }
        } catch (e) {
          // Ignore errors for missing movies
          continue;
        }
      }

      return purchases;
    });
  }

  /// Thêm movie vào purchased list (mua hàng)
  /// TODO: Thêm các phương thức thanh toán sau (payment methods)
  Future<void> addToPurchase(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Add to purchases
    await _db
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .doc(movieId)
        .set({
      'movieId': movieId,
      'purchasedAt': FieldValue.serverTimestamp(),
      'isDownloaded': true,
      'isFinished': false,
    });

    // Get movie details for notification
    final movieDoc = await _db.collection('movies').doc(movieId).get();
    if (movieDoc.exists) {
      final movie = Movie.fromDoc(movieDoc);
      
      // Create purchase notification
      final notification = NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationType.purchase,
        title: t.purchase.notifications.successTitle,
        description: '${t.purchase.notifications.successDescription} "${movie.title}"',
        createdAt: DateTime.now(),
        deepLink: 'movie:$movieId',
        metadata: {
          'movieId': movieId,
          'movieTitle': movie.title,
          'movieImageUrl': movie.imageUrl,
        },
      );

      await _notificationRepo.createNotification(notification);
    }
  }

  /// Xóa movie khỏi purchased list (nếu cần)
  Future<void> removeFromPurchase(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .doc(movieId)
        .delete();
  }

  /// Kiểm tra movie đã được purchased chưa
  Future<bool> isPurchased(String movieId) async {
    final userId = _userId;
    if (userId == null) return false;

    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .doc(movieId)
        .get();

    return doc.exists;
  }

  /// Lấy số lượng items đã purchased
  Future<int> getPurchaseCount() async {
    final userId = _userId;
    if (userId == null) return 0;

    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Lấy thông tin purchase của một movie
  Future<Map<String, dynamic>?> getPurchaseInfo(String movieId) async {
    final userId = _userId;
    if (userId == null) return null;

    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('purchases')
          .doc(movieId)
          .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Stream transactions của một movie
  Stream<List<TransactionItem>> streamTransactions(String movieId) {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('movieId', isEqualTo: movieId)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map((doc) => TransactionItem.fromFirestore(doc.id, doc.data()))
          .toList();
      
      // Sort by createdAt descending in memory (không cần Firestore index)
      transactions.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
      
      return transactions;
    });
  }
}

// Providers
final purchaseProvider = StreamProvider.autoDispose<List<PurchaseItem>>(
  (ref) {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.streamPurchases();
  },
);

final purchaseCountProvider = StreamProvider.autoDispose<int>(
  (ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  },
);

// Provider để check movie đã được purchased chưa (real-time)
final isPurchasedProvider = StreamProvider.autoDispose.family<bool, String>(
  (ref, movieId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .doc(movieId)
        .snapshots()
        .map((doc) => doc.exists);
  },
);

// Provider để lấy transactions của một movie
final movieTransactionsProvider = StreamProvider.autoDispose.family<List<TransactionItem>, String>(
  (ref, movieId) {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.streamTransactions(movieId);
  },
);

// Provider để lấy purchase info
final purchaseInfoProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
  (ref, movieId) async {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.getPurchaseInfo(movieId);
  },
);

