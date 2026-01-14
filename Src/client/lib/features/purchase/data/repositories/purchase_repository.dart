import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/config/api_config.dart';
import '../../models/purchase_item.dart';
import '../../models/transaction_item.dart';
import '../../../notification/models/notification_item.dart';
import '../../../notification/repositories/notification_repository.dart';
import '../../../../i18n/translations.g.dart';

final dioProvider = Provider((ref) => Dio());

final purchaseRepositoryProvider = Provider((ref) => PurchaseRepository(
  ref.watch(dioProvider),
  ref,
  ref.watch(notificationRepositoryProvider),
));

/// Purchase Repository - REST API based
/// TODO: Connect to actual REST API endpoints
class PurchaseRepository {
  PurchaseRepository(this._dio, this._ref, this._notificationRepo);
  
  final Dio _dio;
  final Ref _ref;
  final NotificationRepository _notificationRepo;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // In-memory cache for sample data
  final List<PurchaseItem> _samplePurchases = [];
  final List<TransactionItem> _sampleTransactions = [];

  /// Get purchased items for current user
  Future<List<PurchaseItem>> getPurchases() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.purchaseServiceUrl}/users/$userId/purchases',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map<PurchaseItem>((json) => PurchaseItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _samplePurchases;
    } catch (e) {
      return _samplePurchases;
    }
  }

  /// Stream purchased items (converts Future to Stream for backward compatibility)
  Stream<List<PurchaseItem>> streamPurchases() {
    return Stream.fromFuture(getPurchases());
  }

  /// Add movie to purchases (buy movie)
  Future<void> addToPurchase(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _dio.post(
        '${ApiConfig.purchaseServiceUrl}/users/$userId/purchases',
        data: {'movieId': movieId},
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Add to local sample for demo
      _samplePurchases.add(PurchaseItem(
        id: movieId,
        title: 'Movie $movieId',
        imageUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
        rating: 8.0,
        price: 4.99,
        isDownloaded: true,
        isFinished: false,
      ));
    }

    // Create purchase notification
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.purchase,
      title: t.purchase.notifications.successTitle,
      description: '${t.purchase.notifications.successDescription} movie',
      createdAt: DateTime.now(),
      deepLink: 'movie:$movieId',
      metadata: {
        'movieId': movieId,
      },
    );

    await _notificationRepo.createNotification(notification);
  }

  /// Remove movie from purchases
  Future<void> removeFromPurchase(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _dio.delete(
        '${ApiConfig.purchaseServiceUrl}/users/$userId/purchases/$movieId',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Remove from local sample for demo
      _samplePurchases.removeWhere((p) => p.id == movieId);
    }
  }

  /// Check if movie is purchased
  Future<bool> isPurchased(String movieId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final response = await _dio.get(
        '${ApiConfig.purchaseServiceUrl}/users/$userId/purchases/$movieId',
        options: Options(headers: _headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      return _samplePurchases.any((p) => p.id == movieId);
    }
  }

  /// Get purchase count
  Future<int> getPurchaseCount() async {
    final items = await getPurchases();
    return items.length;
  }

  /// Get purchase info for a movie
  Future<Map<String, dynamic>?> getPurchaseInfo(String movieId) async {
    final userId = _userId;
    if (userId == null) return null;

    try {
      final response = await _dio.get(
        '${ApiConfig.purchaseServiceUrl}/users/$userId/purchases/$movieId',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      final purchase = _samplePurchases.where((p) => p.id == movieId).firstOrNull;
      return purchase?.toJson();
    }
  }

  /// Get transactions for a movie
  Future<List<TransactionItem>> getTransactions(String movieId) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.purchaseServiceUrl}/users/$userId/transactions',
        queryParameters: {'movieId': movieId},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => TransactionItem.fromJson(json)).toList();
      }
      return _sampleTransactions.where((t) => t.movieId == movieId).toList();
    } catch (e) {
      return _sampleTransactions.where((t) => t.movieId == movieId).toList();
    }
  }

  /// Stream transactions for a movie
  Stream<List<TransactionItem>> streamTransactions(String movieId) {
    return Stream.fromFuture(getTransactions(movieId));
  }
}

// Providers
final purchaseProvider = StreamProvider.autoDispose<List<PurchaseItem>>(
  (ref) {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.streamPurchases();
  },
);

final purchaseCountProvider = FutureProvider.autoDispose<int>(
  (ref) async {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.getPurchaseCount();
  },
);

// Provider to check if movie is purchased
final isPurchasedProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, movieId) async {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.isPurchased(movieId);
  },
);

// Provider for movie transactions
final movieTransactionsProvider = StreamProvider.autoDispose.family<List<TransactionItem>, String>(
  (ref, movieId) {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.streamTransactions(movieId);
  },
);

// Provider for purchase info
final purchaseInfoProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
  (ref, movieId) async {
    final repo = ref.watch(purchaseRepositoryProvider);
    return repo.getPurchaseInfo(movieId);
  },
);
