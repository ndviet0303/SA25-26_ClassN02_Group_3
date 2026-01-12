import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/shared_prefs_provider.dart';
import 'playback_state_service.dart';

final playbackStateServiceProvider = Provider<PlaybackStateService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PlaybackStateService(prefs);
});

