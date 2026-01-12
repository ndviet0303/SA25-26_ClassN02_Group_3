import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_fe/core/app_export.dart';

class NumericKeyboard extends StatelessWidget {
  const NumericKeyboard({
    super.key,
    required this.onTextInput,
    required this.onBackspace,
    this.onSubmit,
  });

  final ValueChanged<String> onTextInput;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg    = isDark ? AppColors.dark2 : AppColors.greyscale50;
    final fg    = cs.onSurface;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _Grid(
              fg: fg,
              onTap: onTextInput,
              onBack: onBackspace,
              onSubmit: onSubmit,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.fg,
    required this.onTap,
    required this.onBack,
    required this.onSubmit,
  });

  final Color fg;
  final ValueChanged<String> onTap;
  final VoidCallback onBack;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    const keys = [
      '1','2','3',
      '4','5','6',
      '7','8','9',
      '*','0','<',
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 2 * 12) / 3; // spacing 12
        final h = 48.0; // Giảm height để tiết kiệm space

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: keys.map((k) {
            final isBack = k == '<';
            return SizedBox(
              width: w, height: h,
              child: _KeyButton(
                label: isBack ? null : k,
                isBackspace: isBack,
                fg: fg,
                onTap: () {
                  if (isBack) onBack();
                  else if (k == '✓') onSubmit?.call();
                  else onTap(k);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    this.label,
    required this.fg,
    required this.onTap,
    this.isBackspace = false,
  });

  final String? label;
  final bool isBackspace;
  final Color fg;
  final VoidCallback onTap;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  Timer? _repeat;

  void _startRepeat() {
    // long-press backspace để xoá liên tục
    if (!widget.isBackspace) return;
    _repeat?.cancel();
    _repeat = Timer.periodic(const Duration(milliseconds: 80), (_) => widget.onTap());
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.isBackspace
        ? Icon(Icons.backspace_outlined, color: widget.fg)
        : Text(widget.label!, style: TextStyle(fontSize: 22, color: widget.fg));

    return Listener(
      onPointerUp: (_) => _stopRepeat(),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPressStart: (_) => _startRepeat(),
        onLongPressEnd: (_) => _stopRepeat(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
