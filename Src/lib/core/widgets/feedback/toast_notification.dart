import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum ToastType {
  success,
  error,
  info,
  warning,
}

class ToastNotification extends StatelessWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final IconData? icon;

  const ToastNotification({
    super.key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.icon,
  });

  Color _getAccentColor() {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.primary500; // Màu chủ đạo
      case ToastType.warning:
        return AppColors.secondary500;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.dark2 : AppColors.white;
  }

  Color _getIconBackgroundColor() {
    final accent = _getAccentColor();
    return accent.withOpacity(0.15);
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor();
    final backgroundColor = _getBackgroundColor(context);
    final iconBackgroundColor = _getIconBackgroundColor();
    final iconData = icon ?? _getDefaultIcon();
    final textColor = AppColors.getText(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon với background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Message
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyLRegular.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show toast notification from top
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    // Dismiss previous toast if exists
    dismiss();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        child: ToastNotification(
          message: message,
          type: type,
          duration: duration,
          icon: icon,
        ),
        duration: duration,
        onDismiss: dismiss,
      ),
    );

    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  // Convenience methods
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
      icon: icon,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
      icon: icon,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
      icon: icon,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      icon: icon,
    );
  }
}

class _ToastOverlay extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.child,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation chậm và mượt hơn
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Tăng từ 300ms → 500ms
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide animation với curve mượt hơn
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2), // Bắt đầu từ trên
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Mượt và tự nhiên hơn
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Scale animation để có hiệu ứng bounce nhẹ
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Có hiệu ứng "bounce" nhẹ
    ));

    // Start animation
    _controller.forward();

    // Auto dismiss after delay (accounting for animation time)
    final dismissDelay = widget.duration - const Duration(milliseconds: 400);
    
    Future.delayed(dismissDelay, () {
      if (mounted && !_controller.isAnimating) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
