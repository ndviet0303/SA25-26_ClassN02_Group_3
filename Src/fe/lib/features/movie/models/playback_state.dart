import 'package:equatable/equatable.dart';

class PlaybackState extends Equatable {
  const PlaybackState({
    required this.movieId,
    required this.position,
    required this.playbackSpeed,
    required this.quality,
    required this.lastWatchedAt,
  });

  final String movieId;
  final Duration position;
  final double playbackSpeed;
  final String quality;
  final DateTime lastWatchedAt;

  factory PlaybackState.fromJson(Map<String, dynamic> json) {
    return PlaybackState(
      movieId: json['movieId'] as String,
      position: Duration(
        milliseconds: (json['position'] as num?)?.toInt() ?? 0,
      ),
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      quality: json['quality'] as String? ?? 'Auto',
      lastWatchedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['lastWatchedAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'position': position.inMilliseconds,
      'playbackSpeed': playbackSpeed,
      'quality': quality,
      'lastWatchedAt': lastWatchedAt.millisecondsSinceEpoch,
    };
  }

  PlaybackState copyWith({
    String? movieId,
    Duration? position,
    double? playbackSpeed,
    String? quality,
    DateTime? lastWatchedAt,
  }) {
    return PlaybackState(
      movieId: movieId ?? this.movieId,
      position: position ?? this.position,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      quality: quality ?? this.quality,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    );
  }

  @override
  List<Object?> get props => [
        movieId,
        position,
        playbackSpeed,
        quality,
        lastWatchedAt,
      ];
}

