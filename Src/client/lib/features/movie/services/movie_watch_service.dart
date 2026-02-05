import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/api_config.dart';

final dioProvider = Provider((ref) => Dio());

final movieWatchServiceProvider = Provider((ref) => MovieWatchService(
  dio: ref.watch(dioProvider),
  ref: ref,
));

/// Streaming data returned from play endpoint
class StreamingData {
  final String movieId;
  final String movieName;
  final String? serverName;
  final String? episodeName;
  final String? episodeSlug;
  final String? m3u8Url;
  final String? embedUrl;

  StreamingData({
    required this.movieId,
    required this.movieName,
    this.serverName,
    this.episodeName,
    this.episodeSlug,
    this.m3u8Url,
    this.embedUrl,
  });

  factory StreamingData.fromJson(Map<String, dynamic> json) {
    return StreamingData(
      movieId: json['movieId'] ?? '',
      movieName: json['movieName'] ?? '',
      serverName: json['serverName'],
      episodeName: json['episodeName'],
      episodeSlug: json['episodeSlug'],
      m3u8Url: json['m3u8Url'],
      embedUrl: json['embedUrl'],
    );
  }
}

/// Access check result
class AccessCheckResult {
  final bool hasAccess;
  final StreamingData? streamingData;
  final String? errorMessage;

  AccessCheckResult({
    required this.hasAccess,
    this.streamingData,
    this.errorMessage,
  });
}

/// Movie Watch Service - REST API based
/// Handles access control, view counting, and streaming
class MovieWatchService {
  MovieWatchService({required Dio dio, required Ref ref})
      : _dio = dio,
        _ref = ref;

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Check access and get streaming data for a movie
  /// Returns AccessCheckResult with hasAccess and streamingData
  Future<AccessCheckResult> playMovie(String movieSlug, {String? serverName, String? episodeSlug}) async {
    try {
      String url = '${ApiConfig.movieServiceUrl}/slug/$movieSlug/play';
      
      // Add optional parameters
      Map<String, dynamic> queryParams = {};
      if (serverName != null) queryParams['serverName'] = serverName;
      if (episodeSlug != null) queryParams['episodeSlug'] = episodeSlug;

      final response = await _dio.get(
        url,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return AccessCheckResult(
            hasAccess: true,
            streamingData: StreamingData.fromJson(data['data']),
          );
        }
      }
      
      return AccessCheckResult(
        hasAccess: false,
        errorMessage: 'Unable to load streaming data',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final message = e.response?.data?['message'] ?? 'Premium subscription required';
        return AccessCheckResult(
          hasAccess: false,
          errorMessage: message,
        );
      }
      return AccessCheckResult(
        hasAccess: false,
        errorMessage: e.message ?? 'Network error',
      );
    } catch (e) {
      return AccessCheckResult(
        hasAccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Legacy method - check if user has access to watch a movie
  Future<bool> hasAccess(String movieId) async {
    final result = await playMovie(movieId);
    return result.hasAccess;
  }

  /// Increment view count for a movie
  Future<void> incrementView(String movieId) async {
    try {
      await _dio.post(
        '${ApiConfig.movieServiceUrl}/$movieId/view',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Add movie to user's watch history
  Future<void> addWatchHistory(String movieId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _dio.post(
        '${ApiConfig.customerServiceUrl}/user/$userId/watch-history',
        data: {'movieId': movieId},
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Get user's watch history
  Future<List<Map<String, dynamic>>> getWatchHistory({int limit = 20}) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.customerServiceUrl}/user/$userId/watch-history',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
