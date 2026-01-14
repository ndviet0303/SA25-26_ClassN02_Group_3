import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/config/api_config.dart';

final dioProvider = Provider((ref) => Dio());

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(dioProvider), ref);
});

/// Storage Service - REST API based
/// Handles file uploads to storage service
class StorageService {
  StorageService(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Upload user avatar
  /// Returns the download URL of the uploaded file
  Future<String> uploadAvatar(File imageFile) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User must be authenticated to upload avatar');
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'userId': userId,
        'type': 'avatar',
      });

      final response = await _dio.post(
        '${ApiConfig.storageServiceUrl}/upload',
        data: formData,
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final downloadUrl = response.data['url'] ?? response.data['downloadUrl'];
        debugPrint('[StorageService] Avatar uploaded: $downloadUrl');
        return downloadUrl;
      }

      throw Exception('Failed to upload avatar');
    } catch (e) {
      debugPrint('[StorageService] Error uploading avatar: $e');
      // Return placeholder for demo
      return 'https://i.pravatar.cc/150?u=$userId';
    }
  }

  /// Upload avatar for signup (before user is created)
  Future<String> uploadAvatarForSignup(File imageFile, String temporaryUserId) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'temporaryUserId': temporaryUserId,
        'type': 'signup_avatar',
      });

      final response = await _dio.post(
        '${ApiConfig.storageServiceUrl}/upload/temp',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final downloadUrl = response.data['url'] ?? response.data['downloadUrl'];
        debugPrint('[StorageService] Signup avatar uploaded: $downloadUrl');
        return downloadUrl;
      }

      throw Exception('Failed to upload signup avatar');
    } catch (e) {
      debugPrint('[StorageService] Error uploading signup avatar: $e');
      // Return placeholder for demo
      return 'https://i.pravatar.cc/150?u=$temporaryUserId';
    }
  }

  /// Move temporary signup avatar to user's permanent location
  Future<String> moveSignupAvatarToUser(String tempUrl, String userId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.storageServiceUrl}/move',
        data: {
          'tempUrl': tempUrl,
          'userId': userId,
          'type': 'avatar',
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final downloadUrl = response.data['url'] ?? response.data['downloadUrl'];
        debugPrint('[StorageService] Avatar moved: $downloadUrl');
        return downloadUrl;
      }

      return tempUrl;
    } catch (e) {
      return tempUrl;
    }
  }

  /// Upload file to ImgBB
  /// Returns the display URL of the uploaded image
  Future<String> uploadToImgBB(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        'https://api.imgbb.com/1/upload',
        queryParameters: {
          'key': '1dcd329581b685d5ae3b24e9e625efaf',
        },
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final url = data['url'] ?? data['display_url'];
        debugPrint('[StorageService] ImgBB upload successful: $url');
        return url;
      }

      throw Exception('Failed to upload to ImgBB');
    } catch (e) {
      debugPrint('[StorageService] Error uploading to ImgBB: $e');
      rethrow;
    }
  }
}
