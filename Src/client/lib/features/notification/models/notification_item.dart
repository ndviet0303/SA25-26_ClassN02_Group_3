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
    DateTime? readAtDate;
    DateTime? createdAtDate;

    // Parse readAt
    if (json['readAt'] != null) {
      if (json['readAt'] is String) {
        readAtDate = DateTime.tryParse(json['readAt'] as String);
      } else if (json['readAt'] is int) {
        readAtDate = DateTime.fromMillisecondsSinceEpoch(json['readAt'] as int);
      }
    }

    // Parse createdAt
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        createdAtDate = DateTime.tryParse(json['createdAt'] as String);
      } else if (json['createdAt'] is int) {
        createdAtDate = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int);
      }
    }

    return NotificationItem(
      id: json['id'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? 'general'),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: createdAtDate ?? DateTime.now(),
      readAt: readAtDate,
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
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
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
  newRelease('newRelease'),
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
