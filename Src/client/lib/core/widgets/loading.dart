import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingCustom extends StatefulWidget {

  final String assetName;
  final double size;
  final Color? color;
  final Duration duration;
  final Curve curve;

  const LoadingCustom({
    super.key,
    required this.assetName,
    this.size = 48.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.linear,
  });

  @override
  State<LoadingCustom> createState() => _LoadingCustomState();
}

class _LoadingCustomState extends State<LoadingCustom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: widget.duration)..repeat();
  late final Animation<double> _turns =
  CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _turns,
        child: SvgPicture.asset(
          widget.assetName,
          height: widget.size,
          width: widget.size,
          colorFilter: widget.color == null
              ? null
              : ColorFilter.mode(widget.color!, BlendMode.srcIn),
        ),
      ),
    );
  }
}
