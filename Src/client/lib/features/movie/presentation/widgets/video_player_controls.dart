import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/app_export.dart';
import '../helpers/video_player_helpers.dart';

/// Portrait video controls overlay
class PortraitVideoControls extends StatelessWidget {
  const PortraitVideoControls({
    super.key,
    required this.controller,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onProgressChanged,
  });

  final VideoPlayerController controller;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final Function(double) onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.5),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center controls (backward, play/pause, forward)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, size: 36),
                  color: Colors.white,
                  onPressed: onSeekBackward,
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 64,
                  ),
                  color: Colors.white,
                  onPressed: onPlayPause,
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.forward_10, size: 36),
                  color: Colors.white,
                  onPressed: onSeekForward,
                ),
              ],
            ),
            const Spacer(),
            // Bottom progress bar
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final position = controller.value.position;
    final duration = controller.value.duration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            DurationFormatter.format(position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primary500,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: AppColors.primary500,
                overlayColor: AppColors.primary500.withOpacity(0.3),
              ),
              child: Slider(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble())
                    : 0.0,
                min: 0.0,
                max: duration.inMilliseconds.toDouble(),
                onChanged: onProgressChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DurationFormatter.format(duration),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Landscape video controls - full featured
class LandscapeVideoControls extends StatelessWidget {
  const LandscapeVideoControls({
    super.key,
    required this.controller,
    required this.isPlaying,
    required this.playbackSpeed,
    required this.selectedQuality,
    required this.showSpeedMenu,
    required this.showQualityMenu,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onProgressChanged,
    required this.onSpeedMenuToggle,
    required this.onQualityMenuToggle,
    required this.onSpeedChanged,
  });

  final VideoPlayerController controller;
  final bool isPlaying;
  final double playbackSpeed;
  final String selectedQuality;
  final bool showSpeedMenu;
  final bool showQualityMenu;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final Function(double) onProgressChanged;
  final VoidCallback onSpeedMenuToggle;
  final VoidCallback onQualityMenuToggle;
  final Function(double) onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressBar(context),
            const SizedBox(height: 12),
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final position = controller.value.position;
    final duration = controller.value.duration;

    return Row(
      children: [
        Text(
          DurationFormatter.format(position),
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.primary500,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: AppColors.primary500,
              overlayColor: AppColors.primary500.withOpacity(0.3),
            ),
            child: Slider(
              value: duration.inMilliseconds > 0
                  ? position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble())
                  : 0.0,
              min: 0.0,
              max: duration.inMilliseconds.toDouble(),
              onChanged: onProgressChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          DurationFormatter.format(duration),
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Row(
      children: [
        // Play/Pause
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          color: Colors.white,
          iconSize: 32,
          onPressed: onPlayPause,
        ),
        // Backward 10s
        IconButton(
          icon: const Icon(Icons.replay_10),
          color: Colors.white,
          iconSize: 28,
          onPressed: onSeekBackward,
        ),
        // Forward 10s
        IconButton(
          icon: const Icon(Icons.forward_10),
          color: Colors.white,
          iconSize: 28,
          onPressed: onSeekForward,
        ),
        const Spacer(),
        // Speed control
        _buildSpeedButton(context),
        // Quality control
        _buildQualityButton(context),
      ],
    );
  }

  Widget _buildSpeedButton(BuildContext context) {
    return PopupMenuButton<double>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            '${playbackSpeed}x',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
      color: const Color(0xFF2A2A2A),
      onSelected: onSpeedChanged,
      itemBuilder: (context) => [
        _buildSpeedMenuItem(0.5),
        _buildSpeedMenuItem(0.75),
        _buildSpeedMenuItem(1.0),
        _buildSpeedMenuItem(1.25),
        _buildSpeedMenuItem(1.5),
        _buildSpeedMenuItem(2.0),
      ],
    );
  }

  PopupMenuItem<double> _buildSpeedMenuItem(double speed) {
    return PopupMenuItem(
      value: speed,
      child: Row(
        children: [
          if (playbackSpeed == speed)
            const Icon(Icons.check, color: Colors.white, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(
            '${speed}x',
            style: TextStyle(
              color: playbackSpeed == speed ? Colors.white : Colors.white70,
              fontWeight: playbackSpeed == speed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onQualityMenuToggle,
      icon: const Icon(Icons.settings, color: Colors.white, size: 20),
      label: Text(
        selectedQuality,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
