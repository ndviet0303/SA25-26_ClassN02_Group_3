import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Helper function để query Firestore collection và trả về Future<List<T>>
/// 
/// Ưu điểm:
/// - Viết query như SQL, cực dễ đọc
/// - Hỗ trợ type-safe, auto-complete
/// - Tích hợp tốt với Riverpod
/// 
/// Ví dụ:
/// ```dart
/// final movies = await firestoreCollectionFuture<Movie>(
///   'movies',
///   queryBuilder: (q) => q
///       .where('chieurap', isEqualTo: true)
///       .orderBy('view', descending: true)
///       .limit(100),
///   builder: (data, id) => Movie.fromMap(data, id: id),
/// );
/// ```
Future<List<T>> firestoreCollectionFuture<T>({
  required String collection,
  required T Function(Map<String, dynamic> data, String id) builder,
  Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? queryBuilder,
  FirebaseFirestore? firestore,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;
  Query<Map<String, dynamic>> query = db.collection(collection);
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => builder(doc.data(), doc.id)).toList();
}

/// Helper function để stream Firestore collection và trả về Stream<List<T>>
/// 
/// Ưu điểm:
/// - Real-time updates tự động
/// - Type-safe và auto-complete
/// - Tích hợp tốt với Riverpod StreamProvider
/// 
/// Ví dụ:
/// ```dart
/// final moviesStream = firestoreCollectionStream<Movie>(
///   'movies',
///   queryBuilder: (q) => q
///       .where('chieurap', isEqualTo: true)
///       .orderBy('view', descending: true)
///       .limit(100),
///   builder: (data, id) => Movie.fromMap(data, id: id),
/// );
/// ```
Stream<List<T>> firestoreCollectionStream<T>({
  required String collection,
  required T Function(Map<String, dynamic> data, String id) builder,
  Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? queryBuilder,
  FirebaseFirestore? firestore,
}) {
  final db = firestore ?? FirebaseFirestore.instance;
  Query<Map<String, dynamic>> query = db.collection(collection);
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => builder(doc.data(), doc.id)).toList();
  });
}

/// Helper function để get single document
Future<T?> firestoreDocumentFuture<T>({
  required String collection,
  required String documentId,
  required T Function(Map<String, dynamic> data, String id) builder,
  FirebaseFirestore? firestore,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;
  final doc = await db.collection(collection).doc(documentId).get();
  
  if (!doc.exists) return null;
  return builder(doc.data()!, doc.id);
}

/// Helper function để stream single document
Stream<T?> firestoreDocumentStream<T>({
  required String collection,
  required String documentId,
  required T Function(Map<String, dynamic> data, String id) builder,
  FirebaseFirestore? firestore,
}) {
  final db = firestore ?? FirebaseFirestore.instance;
  return db.collection(collection).doc(documentId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return builder(doc.data()!, doc.id);
  });
}
