import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget wrapper portrait khóa dọc
class OrientationLockWidget extends StatefulWidget {
  const OrientationLockWidget({
    super.key,
    required this.child,
    this.lockPortrait = true,
  });

  final Widget child;
  final bool lockPortrait;

  @override
  State<OrientationLockWidget> createState() => _OrientationLockWidgetState();
}

class _OrientationLockWidgetState extends State<OrientationLockWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.lockPortrait) {
      _lockPortrait();
    }
  }

  @override
  void didUpdateWidget(OrientationLockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lockPortrait != oldWidget.lockPortrait) {
      if (widget.lockPortrait) {
        _lockPortrait();
      } else {
        _unlock();
      }
    }
  }

  @override
  void dispose() {
    if (widget.lockPortrait) {
      _lockPortrait();
    }
    super.dispose();
  }

  Future<void> _lockPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _unlock() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

