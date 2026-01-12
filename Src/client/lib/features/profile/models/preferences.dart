import 'package:equatable/equatable.dart';

class Preferences extends Equatable {
  const Preferences({
    required this.wifiOnlyDownloads,
    required this.autoPlayNextEpisode,
    required this.continueWatching,
    required this.subtitlesEnabled,
    required this.autoRotateScreen,
    required this.autoDownloadAudio,
    required this.videoQuality,
    required this.audioPreference,
    required this.cacheSizeMb,
  });

  final bool wifiOnlyDownloads;
  final bool autoPlayNextEpisode;
  final bool continueWatching;
  final bool subtitlesEnabled;
  final bool autoRotateScreen;
  final bool autoDownloadAudio;
  final String videoQuality;
  final String audioPreference;
  final double cacheSizeMb;

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      wifiOnlyDownloads: json['wifiOnlyDownloads'] as bool? ?? true,
      autoPlayNextEpisode: json['autoPlayNextEpisode'] as bool? ?? true,
      continueWatching: json['continueWatching'] as bool? ?? true,
      subtitlesEnabled: json['subtitlesEnabled'] as bool? ?? true,
      autoRotateScreen: json['autoRotateScreen'] as bool? ?? true,
      autoDownloadAudio: json['autoDownloadAudio'] as bool? ?? false,
      videoQuality: json['videoQuality'] as String? ?? 'Auto',
      audioPreference: json['audioPreference'] as String? ?? 'System Default',
      cacheSizeMb: (json['cacheSizeMb'] as num?)?.toDouble() ?? 128,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wifiOnlyDownloads': wifiOnlyDownloads,
      'autoPlayNextEpisode': autoPlayNextEpisode,
      'continueWatching': continueWatching,
      'subtitlesEnabled': subtitlesEnabled,
      'autoRotateScreen': autoRotateScreen,
      'autoDownloadAudio': autoDownloadAudio,
      'videoQuality': videoQuality,
      'audioPreference': audioPreference,
      'cacheSizeMb': cacheSizeMb,
    };
  }

  Preferences copyWith({
    bool? wifiOnlyDownloads,
    bool? autoPlayNextEpisode,
    bool? continueWatching,
    bool? subtitlesEnabled,
    bool? autoRotateScreen,
    bool? autoDownloadAudio,
    String? videoQuality,
    String? audioPreference,
    double? cacheSizeMb,
  }) {
    return Preferences(
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      autoPlayNextEpisode: autoPlayNextEpisode ?? this.autoPlayNextEpisode,
      continueWatching: continueWatching ?? this.continueWatching,
      subtitlesEnabled: subtitlesEnabled ?? this.subtitlesEnabled,
      autoRotateScreen: autoRotateScreen ?? this.autoRotateScreen,
      autoDownloadAudio: autoDownloadAudio ?? this.autoDownloadAudio,
      videoQuality: videoQuality ?? this.videoQuality,
      audioPreference: audioPreference ?? this.audioPreference,
      cacheSizeMb: cacheSizeMb ?? this.cacheSizeMb,
    );
  }

  static const defaults = Preferences(
    wifiOnlyDownloads: true,
    autoPlayNextEpisode: true,
    continueWatching: true,
    subtitlesEnabled: true,
    autoRotateScreen: true,
    autoDownloadAudio: false,
    videoQuality: 'Auto',
    audioPreference: 'System Default',
    cacheSizeMb: 128,
  );

  @override
  List<Object?> get props => [
        wifiOnlyDownloads,
        autoPlayNextEpisode,
        continueWatching,
        subtitlesEnabled,
        autoRotateScreen,
        autoDownloadAudio,
        videoQuality,
        audioPreference,
        cacheSizeMb,
      ];
}


