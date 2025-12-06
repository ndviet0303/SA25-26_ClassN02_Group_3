import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playback_state.dart';

class PlaybackStateService {
  PlaybackStateService(this._prefs);

  final SharedPreferences _prefs;
  static const String _keyPrefix = 'playback_state_';

  String _getKey(String movieId) => '$_keyPrefix$movieId';

  /// Lưu trạng thái phát của video
  Future<void> savePlaybackState(PlaybackState state) async {
    try {
      final key = _getKey(state.movieId);
      final json = jsonEncode(state.toJson());
      await _prefs.setString(key, json);
    } catch (e) {
      // Log error but don't throw
      print('Error saving playback state: $e');
    }
  }

  /// Lấy trạng thái phát của video
  Future<PlaybackState?> getPlaybackState(String movieId) async {
    try {
      final key = _getKey(movieId);
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlaybackState.fromJson(json);
    } catch (e) {
      print('Error loading playback state: $e');
      return null;
    }
  }

  /// Xóa trạng thái phát của video (khi đã xem xong)
  Future<void> clearPlaybackState(String movieId) async {
    try {
      final key = _getKey(movieId);
      await _prefs.remove(key);
    } catch (e) {
      print('Error clearing playback state: $e');
    }
  }

  /// Lấy tất cả các playback states (để hiển thị "Continue Watching")
  Future<List<PlaybackState>> getAllPlaybackStates() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      final states = <PlaybackState>[];

      for (final key in keys) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            states.add(PlaybackState.fromJson(json));
          } catch (e) {
            // Skip invalid entries
            continue;
          }
        }
      }

      // Sort by last watched time (most recent first)
      states.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
      return states;
    } catch (e) {
      print('Error loading all playback states: $e');
      return [];
    }
  }

  /// Xóa tất cả playback states
  Future<void> clearAllPlaybackStates() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing all playback states: $e');
    }
  }
}

