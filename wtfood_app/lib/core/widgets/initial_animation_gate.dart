import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wtfood_app/core/constants.dart';

class InitialAnimationGate extends StatefulWidget {
  const InitialAnimationGate({required this.child, super.key});

  final Widget child;

  @override
  State<InitialAnimationGate> createState() => _InitialAnimationGateState();
}

class _InitialAnimationGateState extends State<InitialAnimationGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasFinished = false;
  bool _fallbackScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scheduleFallback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleFallback() {
    if (_fallbackScheduled) return;
    _fallbackScheduled = true;

    Future<void>.delayed(const Duration(seconds: 7), () {
      if (!mounted || _hasFinished) return;
      _finishAnimation();
    });
  }

  void _finishAnimation() {
    if (_hasFinished || !mounted) return;
    setState(() {
      _hasFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFinished) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SizedBox(
          width: 500,
          child: Lottie.asset(
            AppAssets.wtfoodAnimation,
            controller: _controller,
            fit: BoxFit.contain,
            repeat: false,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward().whenComplete(_finishAnimation);
            },
          ),
        ),
      ),
    );
  }
}
