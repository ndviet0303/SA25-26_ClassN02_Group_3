import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';
import 'package:movie_fe/core/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie.dart';
import '../../models/playback_state.dart';
import '../../services/playback_state_providers.dart';
import '../widgets/video_error_report_modal.dart';
import '../widgets/movie_info_panel.dart';
import '../../services/movie_watch_service.dart';
import '../widgets/premium_required_dialog.dart';
import '../widgets/no_video_message.dart';
import '../helpers/video_player_helpers.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.movie,
    this.videoUrl,
    this.startPosition,
  });

  final Movie movie;
  final String? videoUrl;
  final Duration? startPosition;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  Timer? _hideControlsTimer;
  Timer? _saveStateTimer;
  double _playbackSpeed = 1.0;
  String _selectedQuality = 'Auto';
  bool _showQualityMenu = false;
  bool _showSpeedMenu = false;
  Duration _lastSavedPosition = Duration.zero;
  bool _viewRecorded = false;
  StreamingData? _streamingData; // Store streaming data from API
  bool _noVideoAvailable = false; // Track when no video URL found

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // Bắt đầu với portrait mode, cho phép expand sang landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _saveStateTimer?.cancel();
    _savePlaybackState();
    _controller?.dispose();
    // Restore portrait lock khi thoát video player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    // Check if movie is FREE - allow without access check
    if (widget.movie.accessType == AccessType.FREE) {
      // Skip access check for free movies
      await _continuePlayerInit();
      return;
    }
    
    // Access check for premium/rental movies
    final watchService = ref.read(movieWatchServiceProvider);
    final result = await watchService.playMovie(widget.movie.slug ?? widget.movie.id);
    
    if (!result.hasAccess) {
      if (mounted) {
        // Show Premium Required dialog
        final shouldNavigate = await showPremiumRequiredDialog(
          context,
          message: result.errorMessage,
        );
        
        if (shouldNavigate && mounted) {
          // Navigate back and then to subscription using GoRouter
          Navigator.of(context).pop();
          // User can navigate to subscription from settings
        } else if (mounted) {
          Navigator.of(context).pop();
        }
      }
      return;
    }
    
    // Store streaming data
    _streamingData = result.streamingData;
    await _continuePlayerInit();
  }
  
  Future<void> _continuePlayerInit() async {
    // Load saved playback state
    final playbackService = ref.read(playbackStateServiceProvider);
    final savedState = await playbackService.getPlaybackState(widget.movie.id);
    
    if (savedState != null) {
      _playbackSpeed = savedState.playbackSpeed;
      _selectedQuality = savedState.quality;
    }

    // Try to get video URL, with priority: widget.videoUrl -> episodes
    String? videoUrl = widget.videoUrl;
    
    // If no videoUrl provided, try to get from episodes first
    if (videoUrl == null || videoUrl.isEmpty) {
      videoUrl = VideoUrlHelper.getVideoUrlWithFallback(widget.movie);
    }
    
    if (videoUrl == null || videoUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _noVideoAvailable = true;
          _isInitialized = true; // Allow UI to render
        });
      }
      return;
    }

    // Try to initialize video player with the URL
    String? lastError;
    bool initialized = await _tryInitializeVideo(videoUrl, savedState);
    
    if (!initialized) {
      lastError = context.i18n.movie.player.cannotLoadM3u8;
    }
    
    // If failed and it's an m3u8 URL, try fallback to embed link
    if (!initialized && videoUrl.contains('.m3u8')) {
      final fallbackUrl = VideoUrlHelper.getFallbackVideoUrl(widget.movie);
      if (fallbackUrl != null && fallbackUrl != videoUrl) {
        if (mounted) {
          ToastNotification.showInfo(
            context,
            message: context.i18n.movie.player.tryingFallback,
            duration: const Duration(seconds: 2),
          );
        }
        initialized = await _tryInitializeVideo(fallbackUrl, savedState);
        if (!initialized) {
          lastError = context.i18n.movie.player.cannotLoadBoth;
        }
      }
    }
    
    if (!initialized && mounted) {
      final diag = await _diagnoseUrl(videoUrl);
      final details = StringBuffer()
        ..writeln(lastError ?? context.i18n.movie.player.unknownError)
        ..writeln('head.status=${diag['head.status']} acceptRanges=${diag['head.acceptRanges']} contentLength=${diag['head.contentLength']}')
        ..writeln('range.status=${diag['range.status']} rangeSupported=${diag['range.supported']}')
        ..writeln('m3u8.ok=${diag['m3u8.ok']} m3u8.ct=${diag['m3u8.contentType']} looksPlaylist=${diag['m3u8.looksLikePlaylist']}')
        ..writeln('platform=${diag['platform']}');
      _showErrorReportModal(videoUrl, details.toString());
    }
  }

  Future<bool> _tryInitializeVideo(String videoUrl, PlaybackState? savedState) async {
    try {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      await _controller!.initialize();
      
      // Seek to saved position or provided start position
      Duration? startPosition = widget.startPosition ?? savedState?.position;
      if (startPosition != null && startPosition > Duration.zero) {
        final duration = _controller!.value.duration;
        if (duration > Duration.zero && startPosition < duration - const Duration(seconds: 10)) {
          await _controller!.seekTo(startPosition);
          _lastSavedPosition = startPosition;
        }
      }

      // Set saved playback speed
      if (savedState != null && savedState.playbackSpeed != 1.0) {
        await _controller!.setPlaybackSpeed(savedState.playbackSpeed);
      }

      _controller!.addListener(_onVideoPlayerUpdate);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = _controller!.value.isPlaying;
        });
        // Record view + history once
        if (!_viewRecorded) {
          _viewRecorded = true;
          final watchService = ref.read(movieWatchServiceProvider);
          unawaited(watchService.incrementView(widget.movie.id));
          unawaited(watchService.addWatchHistory(widget.movie.id));
        }
        _startPeriodicSave();
        _togglePlayPause();
        _startHideControlsTimer();
      }
      
      return true;
    } catch (e) {
      print('[Player] Initialize failed. url=$videoUrl error=$e');
      _controller?.dispose();
      _controller = null;
      
      // Store error for reporting
      if (mounted) {
        // Error will be handled in _initializePlayer
      }
      
      return false;
    }
  }

  Future<Map<String, dynamic>> _diagnoseUrl(String url) async {
    final Map<String, dynamic> result = {
      'url': url,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Theme.of(context).platform.toString(),
    };
    try {
      final dio = Dio(BaseOptions(
        followRedirects: true,
        validateStatus: (s) => true,
        headers: {'User-Agent': 'NozieApp/1.0 (Flutter)'},
      ));

      final headResp = await dio.headUri(Uri.parse(url));
      result['head.status'] = headResp.statusCode;
      result['head.contentType'] = headResp.headers['content-type']?.join(',');
      result['head.contentLength'] = headResp.headers['content-length']?.join(',');
      result['head.acceptRanges'] = headResp.headers['accept-ranges']?.join(',');

      final rangeResp = await dio.getUri(
        Uri.parse(url),
        options: Options(
          method: 'GET',
          headers: {'Range': 'bytes=0-1'},
          responseType: ResponseType.stream,
          followRedirects: true,
          validateStatus: (s) => true,
        ),
      );
      result['range.status'] = rangeResp.statusCode;
      result['range.supported'] = rangeResp.statusCode == 206;

      if (url.contains('.m3u8')) {
        final textResp = await dio.getUri(
          Uri.parse(url),
          options: Options(responseType: ResponseType.plain, validateStatus: (s) => true),
        );
        result['m3u8.ok'] = (textResp.statusCode ?? 0) >= 200 && (textResp.statusCode ?? 0) < 400;
        final ct = (textResp.headers['content-type']?.join(',') ?? '').toLowerCase();
        result['m3u8.contentType'] = ct;
        result['m3u8.looksLikePlaylist'] = (textResp.data is String) && (textResp.data as String).contains('#EXTM3U');
      }
    } catch (e) {
      result['diagnose.error'] = e.toString();
    }

    debugPrint('[Player][Diagnose] ${jsonEncode(result)}');
    return result;
  }

  void _onVideoPlayerUpdate() {
    if (_controller == null) return;
    
    if (_controller!.value.isPlaying && !_isPlaying) {
      setState(() => _isPlaying = true);
    } else if (!_controller!.value.isPlaying && _isPlaying) {
      setState(() => _isPlaying = false);
    }
  }

  void _showErrorReportModal(String videoUrl, String errorMessage) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VideoErrorReportModal(
        movie: widget.movie,
        videoUrl: videoUrl,
        errorMessage: errorMessage,
      ),
    ).then((shouldClose) {
      if (shouldClose == true || shouldClose == null) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _startPeriodicSave() {
    _saveStateTimer?.cancel();
    _saveStateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _savePlaybackState();
    });
  }

  Future<void> _handleTrailer(String url) async {
    if (VideoUrlHelper.isDirectUrl(url)) {
      setState(() {
        _isInitialized = false;
        _showControls = true;
      });
      await _tryInitializeVideo(url, null);
      return;
    }

    try {
      final uri = Uri.parse(url);
      final mode = VideoUrlHelper.isYouTubeUrl(url) ? LaunchMode.externalApplication : LaunchMode.inAppBrowserView;
      final canOpen = await canLaunchUrl(uri);
      if (!canOpen) {
        _showOpenTrailerError();
        return;
      }
      final ok = await launchUrl(
        uri,
        mode: mode,
        webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
      );
      if (!ok) _showOpenTrailerError();
    } catch (_) {
      _showOpenTrailerError();
    }
  }



  void _showOpenTrailerError() {
    if (!mounted) return;
    ToastNotification.showError(
      context,
      message: context.i18n.movie.player.cannotOpenTrailer,
    );
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      _showQualityMenu = false;
      _showSpeedMenu = false;
    });
    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      _showControls = true;
    });
    _savePlaybackState(); // Save immediately on play/pause
    _startHideControlsTimer();
  }

  void _seekRelative(Duration duration) {
    if (_controller == null) return;
    final currentPosition = _controller!.value.position;
    final totalDuration = _controller!.value.duration;
    final newPosition = currentPosition + duration;
    
    Duration clampedPosition;
    if (newPosition < Duration.zero) {
      clampedPosition = Duration.zero;
    } else if (newPosition > totalDuration) {
      clampedPosition = totalDuration;
    } else {
      clampedPosition = newPosition;
    }
    
    _controller!.seekTo(clampedPosition);
    _lastSavedPosition = clampedPosition;
    _savePlaybackState(); // Save immediately on seek
    setState(() => _showControls = true);
    _startHideControlsTimer();
  }


  Future<void> _savePlaybackState() async {
    if (_controller == null || !_isInitialized) return;

    try {
      final position = _controller!.value.position;
      final duration = _controller!.value.duration;
      
      // Only save if position has changed significantly (at least 3 seconds)
      // and not at the end (within 5 seconds of end)
      if ((position - _lastSavedPosition).abs() < const Duration(seconds: 3)) {
        return;
      }

      // Don't save if near the end (within 5 seconds)
      if (position >= duration - const Duration(seconds: 5)) {
        return;
      }

      final playbackService = ref.read(playbackStateServiceProvider);
      final state = PlaybackState(
        movieId: widget.movie.id,
        position: position,
        playbackSpeed: _playbackSpeed,
        quality: _selectedQuality,
        lastWatchedAt: DateTime.now(),
      );

      await playbackService.savePlaybackState(state);
      _lastSavedPosition = position;
    } catch (e) {
      // Silently handle errors
      print('Error saving playback state: $e');
    }
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
      _isFullscreen = false;
      _showControls = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading only if not initialized AND no video available message not shown
    if (!_isInitialized && !_noVideoAvailable) {
      return Scaffold(
        backgroundColor: AppColors.getBackground(context),
        body: Center(
          child: LoadingCustom(
            assetName: ImageConstant.loadingIcon,
            size: 60,
            color: AppColors.primary500,
          ),
        ),
      );
    }

    // Check if in landscape mode (fullscreen)
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    if (isLandscape) {
      return _buildLandscapePlayer();
    } else {
      return _buildPortraitPlayer();
    }
  }

  Widget _buildPortraitPlayer() {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getText(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen, color: AppColors.getText(context)),
            onPressed: _enterFullscreen,
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player Section
          _noVideoAvailable
              ? NoVideoMessage(movieTitle: widget.movie.title)
              : GestureDetector(
                  onTap: _toggleControls,
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayer(_controller!),
                      ),
                      if (_showControls) _buildPortraitVideoControls(),
                    ],
                  ),
                ),
          // Movie Info Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MovieInfoPanel(
                movie: widget.movie,
                onEpisodeSelected: (url) async {
                  // Switch to selected episode URL
                  setState(() {
                    _isInitialized = false;
                    _showControls = true;
                    _noVideoAvailable = false; // Reset flag
                  });
                  await _tryInitializeVideo(url, null);
                },
                onTrailerSelected: (url) async {
                  await _handleTrailer(url);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPortraitVideoControls() {
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildProgressBar(),
            _buildPortraitBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getLine(context)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.getText(context),
        ),
      ),
    );
  }

  Widget _buildPortraitBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _togglePlayPause,
          ),
          const Gap(16),
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
            onPressed: () => _seekRelative(const Duration(seconds: -10)),
          ),
          const Gap(8),
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
            onPressed: () => _seekRelative(const Duration(seconds: 10)),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.fullscreen, color: AppColors.getText(context)),
            onPressed: _enterFullscreen,
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapePlayer() {
    // If no video, show message in landscape too
    if (_noVideoAvailable) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: NoVideoMessage(movieTitle: widget.movie.title),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
            if (_showControls) _buildControls(),
            _buildTopBar(),
          ],
        ),
      ),
    );
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    setState(() {
      _isFullscreen = true;
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.getText(context)),
                  onPressed: _exitFullscreen,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.movie.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.movie.directorString.isNotEmpty)
                        Text(
                          widget.movie.directorString,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showQualityMenu = !_showQualityMenu;
                      _showSpeedMenu = false;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: _exitFullscreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_showQualityMenu || _showSpeedMenu) _buildSettingsMenu(),
              _buildProgressBar(),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showSpeedMenu) ...[
            Text(
              'Playback Speed',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                final isSelected = _playbackSpeed == speed;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _playbackSpeed = speed;
                      _controller?.setPlaybackSpeed(speed);
                      _showSpeedMenu = false;
                    });
                    _savePlaybackState(); // Save immediately on speed change
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary500 : AppColors.dark4,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${speed}x',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (_showQualityMenu) ...[
            if (_showSpeedMenu) const Gap(24),
            Text(
              'Quality',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Auto', '1080p', '720p', '480p'].map((quality) {
                final isSelected = _selectedQuality == quality;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedQuality = quality;
                      _showQualityMenu = false;
                    });
                    _savePlaybackState(); // Save immediately on quality change
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary500 : AppColors.dark4,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quality,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (_) {
              // Save state after user finishes dragging
              _savePlaybackState();
            },
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.primary500,
                bufferedColor: Colors.white.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(_controller!.value.position),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                DurationFormatter.format(_controller!.value.duration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _togglePlayPause,
          ),
          const Gap(16),
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
            onPressed: () => _seekRelative(const Duration(seconds: -10)),
          ),
          const Gap(8),
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
            onPressed: () => _seekRelative(const Duration(seconds: 10)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSpeedMenu = !_showSpeedMenu;
                _showQualityMenu = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed, color: Colors.white, size: 20),
                  const Gap(4),
                  Text(
                    '${_playbackSpeed}x',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          GestureDetector(
            onTap: () {
              setState(() {
                _showQualityMenu = !_showQualityMenu;
                _showSpeedMenu = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.high_quality, color: Colors.white, size: 20),
                  const Gap(4),
                  Text(
                    _selectedQuality,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              // Already in fullscreen
            },
          ),
        ],
      ),
    );
  }
}

