import '../../../../core/models/movie.dart';

/// Video URL helper utilities
class VideoUrlHelper {
  /// Get video URL with fallback logic
  /// Priority: Episodes (linkM3u8 -> linkEmbed) -> TrailerUrl (only if direct stream)
  static String? getVideoUrlWithFallback(Movie movie) {
    // 1) Prioritize episodes first
    if (movie.episodes != null && movie.episodes!.isNotEmpty) {
      final firstEpisode = movie.episodes!.first;
      
      if (firstEpisode['serverData'] != null && firstEpisode['serverData'] is List) {
        final serverData = firstEpisode['serverData'] as List;
        if (serverData.isNotEmpty) {
          final firstVideo = serverData.first;
          // Prefer m3u8 for better quality (direct stream)
          if (firstVideo['linkM3u8'] != null &&
              (firstVideo['linkM3u8'].toString().contains('.m3u8') ||
               firstVideo['linkM3u8'].toString().contains('.mp4'))) {
            return firstVideo['linkM3u8'].toString();
          }
          if (firstVideo['linkEmbed'] != null) {
            return firstVideo['linkEmbed'].toString();
          }
        }
      }
      
      if (firstEpisode['url'] != null) {
        return firstEpisode['url'].toString();
      }
      if (firstEpisode['videoUrl'] != null) {
        return firstEpisode['videoUrl'].toString();
      }
    }
    
    // 2) Fallback to trailerUrl only if it's a direct stream (not YouTube)
    if (movie.trailerUrl != null && movie.trailerUrl!.isNotEmpty) {
      final t = movie.trailerUrl!;
      final isDirectStream = t.contains('.m3u8') || t.contains('.mp4');
      final isYouTube = t.contains('youtube.com') || t.contains('youtu.be');
      if (isDirectStream && !isYouTube) {
        return t;
      }
      // Skip YouTube or non-stream trailer for video_player
    }
    
    return null;
  }

  /// Get fallback embed URL
  static String? getFallbackVideoUrl(Movie movie) {
    if (movie.episodes != null && movie.episodes!.isNotEmpty) {
      final firstEpisode = movie.episodes!.first;
      
      if (firstEpisode['serverData'] != null && firstEpisode['serverData'] is List) {
        final serverData = firstEpisode['serverData'] as List;
        if (serverData.isNotEmpty) {
          final firstVideo = serverData.first;
          // Return embed link as fallback
          if (firstVideo['linkEmbed'] != null) {
            return firstVideo['linkEmbed'].toString();
          }
        }
      }
    }
    return null;
  }

  /// Check if URL is a direct video URL
  static bool isDirectUrl(String url) =>
      url.endsWith('.m3u8') || url.endsWith('.mp4') || url.contains('.m3u8') || url.contains('.mp4');

  /// Check if URL is YouTube
  static bool isYouTubeUrl(String url) =>
      url.contains('youtube.com') || url.contains('youtu.be');
}

/// Duration formatting utilities
class DurationFormatter {
  /// Format duration to MM:SS or HH:MM:SS
  static String format(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
