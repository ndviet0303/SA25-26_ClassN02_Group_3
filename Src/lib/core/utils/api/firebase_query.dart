import 'package:cloud_firestore/cloud_firestore.dart';

/// Query builder dạng chain cho Firestore
/// 
/// Ưu điểm:
/// - Chain API, cực dễ đọc và viết
/// - Type-safe với auto-complete
/// - Tương tự FirebaseQuery
/// 
/// Ví dụ:
/// ```dart
/// final results = await FirebaseQuery.collection('users')
///   .eq('active', true)
///   .gt('score', 100)
///   .orderBy('score', descending: true)
///   .limit(10)
///   .get();
/// ```
class FirebaseQuery {
  final Query<Map<String, dynamic>> _query;

  FirebaseQuery(this._query);

  /// Khởi tạo query từ collection
  factory FirebaseQuery.collection(String collection, {FirebaseFirestore? firestore}) {
    final db = firestore ?? FirebaseFirestore.instance;
    return FirebaseQuery(db.collection(collection));
  }

  /// Equal: where('field', isEqualTo: value)
  FirebaseQuery eq(String field, dynamic value) {
    return FirebaseQuery(_query.where(field, isEqualTo: value));
  }

  /// Not equal: where('field', isNotEqualTo: value)
  FirebaseQuery neq(String field, dynamic value) {
    return FirebaseQuery(_query.where(field, isNotEqualTo: value));
  }

  /// Less than: where('field', isLessThan: value)
  FirebaseQuery lt(String field, dynamic value) {
    return FirebaseQuery(_query.where(field, isLessThan: value));
  }

  /// Less than or equal: where('field', isLessThanOrEqualTo: value)
  FirebaseQuery lte(String field, dynamic value) {
    return FirebaseQuery(_query.where(field, isLessThanOrEqualTo: value));
  }

  /// Greater than: where('field', isGreaterThan: value)
  FirebaseQuery gt(String field, dynamic value) {
    return FirebaseQuery(_query.where(field, isGreaterThan: value));
  }

  /// Greater than or equal: where('field', isGreaterThanOrEqualTo: value)
  FirebaseQuery gte(String field, dynamic value) {
    return FirebaseQuery(_query.where(field, isGreaterThanOrEqualTo: value));
  }

  /// Array contains: where('field', arrayContains: value)
  FirebaseQuery arrayContains(String field, dynamic value) {
    return FirebaseQuery(_query.where(field, arrayContains: value));
  }

  /// Array contains any: where('field', arrayContainsAny: values)
  FirebaseQuery arrayContainsAny(String field, List<dynamic> values) {
    return FirebaseQuery(_query.where(field, arrayContainsAny: values));
  }

  /// Where in: where('field', whereIn: values)
  FirebaseQuery whereIn(String field, List<dynamic> values) {
    return FirebaseQuery(_query.where(field, whereIn: values));
  }

  /// Order by: orderBy('field', descending: descending)
  FirebaseQuery orderBy(String field, {bool descending = false}) {
    return FirebaseQuery(_query.orderBy(field, descending: descending));
  }

  /// Limit: limit(count)
  FirebaseQuery limit(int count) {
    return FirebaseQuery(_query.limit(count));
  }

  /// Start at: startAt(values)
  FirebaseQuery startAt(List<dynamic> values) {
    return FirebaseQuery(_query.startAt(values));
  }

  /// Start after: startAfter(values)
  FirebaseQuery startAfter(List<dynamic> values) {
    return FirebaseQuery(_query.startAfter(values));
  }

  /// End at: endAt(values)
  FirebaseQuery endAt(List<dynamic> values) {
    return FirebaseQuery(_query.endAt(values));
  }

  /// End before: endBefore(values)
  FirebaseQuery endBefore(List<dynamic> values) {
    return FirebaseQuery(_query.endBefore(values));
  }

  /// Get snapshot: get()
  Future<QuerySnapshot<Map<String, dynamic>>> get() {
    return _query.get();
  }

  /// Stream snapshot: snapshots()
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots() {
    return _query.snapshots();
  }

  /// Get internal query
  Query<Map<String, dynamic>> get query => _query;
}
