import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.deepLink,
    this.metadata,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final String? deepLink; // Deep link when tapping notification
  final Map<String, dynamic>? metadata; // Additional data

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    Timestamp? readTimestamp;
    Timestamp? createdAtTimestamp;

    if (json['readAt'] != null) {
      if (json['readAt'] is Timestamp) {
        readTimestamp = json['readAt'] as Timestamp;
      } else if (json['readAt'] is Map) {
        readTimestamp = Timestamp.fromMillisecondsSinceEpoch(
          (json['readAt']['_seconds'] as int) * 1000,
        );
      }
    }

    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        createdAtTimestamp = json['createdAt'] as Timestamp;
      } else if (json['createdAt'] is Map) {
        createdAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
          (json['createdAt']['_seconds'] as int) * 1000,
        );
      }
    }

    return NotificationItem(
      id: json['id'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? 'general'),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(),
      readAt: readTimestamp?.toDate(),
      imageUrl: json['imageUrl'] as String?,
      deepLink: json['deepLink'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'imageUrl': imageUrl,
      'deepLink': deepLink,
      'metadata': metadata,
    };
  }

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? readAt,
    String? imageUrl,
    String? deepLink,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      imageUrl: imageUrl ?? this.imageUrl,
      deepLink: deepLink ?? this.deepLink,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isRead => readAt != null;

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        createdAt,
        readAt,
        imageUrl,
        deepLink,
        metadata,
      ];
}

enum NotificationType {
  general('general'),
  purchase('purchase'),
  recommendation('recommendation'),
  authorUpdate('authorUpdate'),
  priceDrop('priceDrop'),
  newSeries('newSeries'),
  system('system'),
  tips('tips'),
  survey('survey');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

