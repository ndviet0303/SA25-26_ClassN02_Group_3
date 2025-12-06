import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  const NotificationSettings({
    required this.newRecommendation,
    required this.newBookSeries,
    required this.authorUpdates,
    required this.priceDrops,
    required this.purchase,
    required this.appSystem,
    required this.tipsServices,
    required this.survey,
  });

  final bool newRecommendation;
  final bool newBookSeries;
  final bool authorUpdates;
  final bool priceDrops;
  final bool purchase;
  final bool appSystem;
  final bool tipsServices;
  final bool survey;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      newRecommendation: json['newRecommendation'] as bool? ?? true,
      newBookSeries: json['newBookSeries'] as bool? ?? false,
      authorUpdates: json['authorUpdates'] as bool? ?? false,
      priceDrops: json['priceDrops'] as bool? ?? true,
      purchase: json['purchase'] as bool? ?? true,
      appSystem: json['appSystem'] as bool? ?? true,
      tipsServices: json['tipsServices'] as bool? ?? false,
      survey: json['survey'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newRecommendation': newRecommendation,
      'newBookSeries': newBookSeries,
      'authorUpdates': authorUpdates,
      'priceDrops': priceDrops,
      'purchase': purchase,
      'appSystem': appSystem,
      'tipsServices': tipsServices,
      'survey': survey,
    };
  }

  NotificationSettings copyWith({
    bool? newRecommendation,
    bool? newBookSeries,
    bool? authorUpdates,
    bool? priceDrops,
    bool? purchase,
    bool? appSystem,
    bool? tipsServices,
    bool? survey,
  }) {
    return NotificationSettings(
      newRecommendation: newRecommendation ?? this.newRecommendation,
      newBookSeries: newBookSeries ?? this.newBookSeries,
      authorUpdates: authorUpdates ?? this.authorUpdates,
      priceDrops: priceDrops ?? this.priceDrops,
      purchase: purchase ?? this.purchase,
      appSystem: appSystem ?? this.appSystem,
      tipsServices: tipsServices ?? this.tipsServices,
      survey: survey ?? this.survey,
    );
  }

  static const defaults = NotificationSettings(
    newRecommendation: true,
    newBookSeries: false,
    authorUpdates: false,
    priceDrops: true,
    purchase: true,
    appSystem: true,
    tipsServices: false,
    survey: false,
  );

  @override
  List<Object?> get props => [
        newRecommendation,
        newBookSeries,
        authorUpdates,
        priceDrops,
        purchase,
        appSystem,
        tipsServices,
        survey,
      ];
}


