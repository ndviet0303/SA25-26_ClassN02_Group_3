import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../auth/auth_providers.dart';
import '../config/api_config.dart';

final streamingRepositoryProvider = Provider<StreamingRepository>((ref) {
  return StreamingRepository(Dio(), ref);
});

/// Streaming Repository - REST API based
/// Handles video playback URLs, episodes, and view counting
class StreamingRepository {
  StreamingRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    if (_userId != null) 'X-User-Id': _userId!,
  };

  // ============= VIEW COUNTING =============

  /// Increment view count by movie ID
  Future<void> incrementViewById(String movieId) async {
    try {
      await _dio.post(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/view',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Silently ignore view counting errors
    }
  }

  /// Increment view count by movie slug
  Future<void> incrementViewBySlug(String slug) async {
    try {
      await _dio.post(
        '${ApiConfig.movieServiceUrl}/movies/slug/$slug/view',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Silently ignore view counting errors
    }
  }

  // ============= PLAY URL =============

  /// Get play URL by movie ID
  /// Returns streaming data with m3u8 or embed URLs
  Future<PlayResult> getPlayUrl(String movieId, {int server = 0, int episode = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/play',
        queryParameters: {
          'server': server,
          'episode': episode,
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return PlayResult(
          success: true,
          data: PlayUrlData.fromJson(data),
        );
      }
      return PlayResult(success: false, error: 'Failed to load play URL');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return PlayResult(
          success: false,
          error: e.response?.data?['message'] ?? 'Premium subscription required',
          requiresPremium: true,
        );
      }
      return PlayResult(success: false, error: e.message ?? 'Network error');
    } catch (e) {
      return PlayResult(success: false, error: e.toString());
    }
  }

  /// Get play URL by movie slug
  Future<PlayResult> getPlayUrlBySlug(String slug, {int server = 0, int episode = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/slug/$slug/play',
        queryParameters: {
          'server': server,
          'episode': episode,
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return PlayResult(
          success: true,
          data: PlayUrlData.fromJson(data),
        );
      }
      return PlayResult(success: false, error: 'Failed to load play URL');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return PlayResult(
          success: false,
          error: e.response?.data?['message'] ?? 'Premium subscription required',
          requiresPremium: true,
        );
      }
      return PlayResult(success: false, error: e.message ?? 'Network error');
    } catch (e) {
      return PlayResult(success: false, error: e.toString());
    }
  }

  // ============= EPISODES =============

  /// Get episodes by movie ID
  Future<EpisodesResult> getEpisodes(String movieId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/episodes',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return EpisodesResult(
          success: true,
          data: EpisodesData.fromJson(data),
        );
      }
      return EpisodesResult(success: false, error: 'Failed to load episodes');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return EpisodesResult(
          success: false,
          error: e.response?.data?['message'] ?? 'Premium subscription required',
          requiresPremium: true,
        );
      }
      return EpisodesResult(success: false, error: e.message ?? 'Network error');
    } catch (e) {
      return EpisodesResult(success: false, error: e.toString());
    }
  }

  /// Get episodes by movie slug
  Future<EpisodesResult> getEpisodesBySlug(String slug) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/slug/$slug/episodes',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return EpisodesResult(
          success: true,
          data: EpisodesData.fromJson(data),
        );
      }
      return EpisodesResult(success: false, error: 'Failed to load episodes');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return EpisodesResult(
          success: false,
          error: e.response?.data?['message'] ?? 'Premium subscription required',
          requiresPremium: true,
        );
      }
      return EpisodesResult(success: false, error: e.message ?? 'Network error');
    } catch (e) {
      return EpisodesResult(success: false, error: e.toString());
    }
  }
}

// ============= MODELS =============

class PlayResult {
  final bool success;
  final PlayUrlData? data;
  final String? error;
  final bool requiresPremium;

  PlayResult({
    required this.success,
    this.data,
    this.error,
    this.requiresPremium = false,
  });
}

class PlayUrlData {
  final String movieId;
  final String movieName;
  final String? serverName;
  final String? episodeName;
  final String? episodeSlug;
  final String? m3u8Url;
  final String? embedUrl;

  PlayUrlData({
    required this.movieId,
    required this.movieName,
    this.serverName,
    this.episodeName,
    this.episodeSlug,
    this.m3u8Url,
    this.embedUrl,
  });

  factory PlayUrlData.fromJson(Map<String, dynamic> json) {
    return PlayUrlData(
      movieId: json['movieId'] ?? '',
      movieName: json['movieName'] ?? '',
      serverName: json['serverName'],
      episodeName: json['episodeName'],
      episodeSlug: json['episodeSlug'],
      m3u8Url: json['m3u8Url'],
      embedUrl: json['embedUrl'],
    );
  }

  /// Get the best available URL for playback
  String? get playableUrl => m3u8Url ?? embedUrl;
}

class EpisodesResult {
  final bool success;
  final EpisodesData? data;
  final String? error;
  final bool requiresPremium;

  EpisodesResult({
    required this.success,
    this.data,
    this.error,
    this.requiresPremium = false,
  });
}

class EpisodesData {
  final String movieId;
  final String movieName;
  final String? type;
  final List<ServerGroup> servers;

  EpisodesData({
    required this.movieId,
    required this.movieName,
    this.type,
    required this.servers,
  });

  factory EpisodesData.fromJson(Map<String, dynamic> json) {
    final serversJson = json['servers'] as List? ?? [];
    return EpisodesData(
      movieId: json['movieId'] ?? '',
      movieName: json['movieName'] ?? '',
      type: json['type'],
      servers: serversJson.map((e) => ServerGroup.fromJson(e)).toList(),
    );
  }

  /// Get total episode count across all servers
  int get totalEpisodes {
    if (servers.isEmpty) return 0;
    return servers.first.episodes.length;
  }

  /// Get first server's episodes for convenience
  List<Episode> get episodes => servers.isNotEmpty ? servers.first.episodes : [];
}

class ServerGroup {
  final String serverName;
  final List<Episode> episodes;

  ServerGroup({
    required this.serverName,
    required this.episodes,
  });

  factory ServerGroup.fromJson(Map<String, dynamic> json) {
    final episodesJson = json['episodes'] as List? ?? [];
    return ServerGroup(
      serverName: json['serverName'] ?? json['server_name'] ?? '',
      episodes: episodesJson.map((e) => Episode.fromJson(e)).toList(),
    );
  }
}

class Episode {
  final String name;
  final String slug;
  final String? m3u8Url;
  final String? embedUrl;

  Episode({
    required this.name,
    required this.slug,
    this.m3u8Url,
    this.embedUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      name: json['name'] ?? json['episodeName'] ?? '',
      slug: json['slug'] ?? json['episodeSlug'] ?? '',
      m3u8Url: json['m3u8Url'] ?? json['link_m3u8'],
      embedUrl: json['embedUrl'] ?? json['link_embed'],
    );
  }

  String? get playableUrl => m3u8Url ?? embedUrl;
}

// ============= PROVIDERS =============

/// Provider to get play URL for a movie
final playUrlProvider = FutureProvider.autoDispose.family<PlayResult, PlayRequest>((ref, request) {
  final repo = ref.watch(streamingRepositoryProvider);
  if (request.useSlug) {
    return repo.getPlayUrlBySlug(request.id, server: request.server, episode: request.episode);
  }
  return repo.getPlayUrl(request.id, server: request.server, episode: request.episode);
});

/// Provider to get episodes for a movie
final episodesProvider = FutureProvider.autoDispose.family<EpisodesResult, EpisodesRequest>((ref, request) {
  final repo = ref.watch(streamingRepositoryProvider);
  if (request.useSlug) {
    return repo.getEpisodesBySlug(request.id);
  }
  return repo.getEpisodes(request.id);
});

class PlayRequest {
  final String id;
  final bool useSlug;
  final int server;
  final int episode;

  PlayRequest({
    required this.id,
    this.useSlug = false,
    this.server = 0,
    this.episode = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          useSlug == other.useSlug &&
          server == other.server &&
          episode == other.episode;

  @override
  int get hashCode => id.hashCode ^ useSlug.hashCode ^ server.hashCode ^ episode.hashCode;
}

class EpisodesRequest {
  final String id;
  final bool useSlug;

  EpisodesRequest({required this.id, this.useSlug = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodesRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          useSlug == other.useSlug;

  @override
  int get hashCode => id.hashCode ^ useSlug.hashCode;
}
