
import 'package:design_system/src/foundation/motion/app_motion.dart';
import 'package:material_ui/material_ui.dart';

class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1200),
  }) : assert(duration > Duration.zero);

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;

      if (_reduceMotion == false) {
        _controller
          ..stop()
          ..repeat();
      }
    }
  }

  void _updateMotion() {
    final shouldReduce = AppMotion.shouldReduceMotion(context);

    if (_reduceMotion == shouldReduce) return;

    _reduceMotion = shouldReduce;

    if (shouldReduce) {
      _controller
        ..stop()
        ..value = 0.5;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor =
        widget.baseColor ?? theme.colorScheme.surfaceContainerHighest;

    final highlightColor =
        widget.highlightColor ?? theme.colorScheme.surface;

    if (_reduceMotion == true) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final position = -1 + (_controller.value * 3);

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(position - 1, 0),
              end: Alignment(position + 1, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
