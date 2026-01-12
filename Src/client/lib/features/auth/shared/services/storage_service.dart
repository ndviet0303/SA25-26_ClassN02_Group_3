import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service to handle file uploads to Firebase Storage
class StorageService {
  StorageService({
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  /// Upload user avatar to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to upload avatar');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avatar_$timestamp.jpg';
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('avatar')
          .child(fileName);

      debugPrint('[StorageService] Uploading avatar: users/${user.uid}/avatar/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('[StorageService] Avatar uploaded successfully: $downloadUrl');

      // Delete old avatar if exists (optional - keep last 1 avatar)
      try {
        final listResult = await _storage
            .ref()
            .child('users')
            .child(user.uid)
            .child('avatar')
            .listAll();
        
        // Delete all old avatars except the new one
        for (final item in listResult.items) {
          if (item.name != fileName) {
            await item.delete();
            debugPrint('[StorageService] Deleted old avatar: ${item.name}');
          }
        }
      } catch (e) {
        debugPrint('[StorageService] Could not delete old avatars: $e');
      }

      return downloadUrl;
    } catch (error) {
      debugPrint('[StorageService] Error uploading avatar: $error');
      rethrow;
    }
  }

  /// Upload avatar for new user registration (before user is created)
  /// Returns the download URL of the uploaded file
  Future<String> uploadAvatarForSignup(
    File imageFile,
    String temporaryUserId,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avatar_$timestamp.jpg';
      final ref = _storage
          .ref()
          .child('temp_signup')
          .child(temporaryUserId)
          .child(fileName);

      debugPrint('[StorageService] Uploading avatar for signup: temp_signup/$temporaryUserId/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('[StorageService] Avatar uploaded for signup: $downloadUrl');

      return downloadUrl;
    } catch (error) {
      debugPrint('[StorageService] Error uploading avatar for signup: $error');
      rethrow;
    }
  }

  /// Move temporary signup avatar to user's permanent location
  Future<String> moveSignupAvatarToUser(String tempUrl, String userId) async {
    try {
      // Extract path from temp URL
      final uri = Uri.parse(tempUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the path in storage
      final tempPath = pathSegments.where((seg) => seg.startsWith('temp_signup')).join('/');
      
      if (tempPath.isEmpty) {
        // If we can't extract path, just return the URL as-is
        return tempUrl;
      }

      // Create new reference for user
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avatar_$timestamp.jpg';
      final newRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('avatar')
          .child(fileName);

      // Download from temp and upload to permanent location
      final tempRef = _storage.refFromURL(tempUrl);
      final data = await tempRef.getData();
      
      if (data == null) {
        return tempUrl; // Return original if download fails
      }

      await newRef.putData(
        data,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await newRef.getDownloadURL();

      // Delete temp file
      try {
        await tempRef.delete();
      } catch (e) {
        debugPrint('[StorageService] Could not delete temp avatar: $e');
      }

      debugPrint('[StorageService] Moved signup avatar to user location: $downloadUrl');

      return downloadUrl;
    } catch (error) {
      debugPrint('[StorageService] Error moving signup avatar: $error');
      // Return original URL if move fails
      return tempUrl;
    }
  }
}

