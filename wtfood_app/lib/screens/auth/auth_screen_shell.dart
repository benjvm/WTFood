import 'package:flutter/material.dart';

class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.child,
    this.appBar,
    this.horizontalPadding = 28,
    this.topPadding = 20,
    this.bottomPadding = 28,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: appBar,
      body: Stack(
        children: [
          const _AuthBackgroundDecorations(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  bottomPadding,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackgroundDecorations extends StatelessWidget {
  const _AuthBackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            top: -56,
            left: -48,
            child: _AccentCircle(
              size: 128,
              color: Color(0xFF66DB6A),
            ),
          ),
          Positioned(
            top: -34,
            left: 38,
            child: _AccentCircle(
              size: 102,
              color: Color(0xFFF4CC58),
            ),
          ),
          Positioned(
            bottom: -46,
            right: 34,
            child: _AccentCircle(
              size: 110,
              color: Color(0xFFF4CC58),
            ),
          ),
          Positioned(
            bottom: -62,
            right: -20,
            child: _AccentCircle(
              size: 136,
              color: Color(0xFF66DB6A),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentCircle extends StatelessWidget {
  const _AccentCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AccentRing extends StatelessWidget {
  const _AccentRing({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.4),
      ),
    );
  }
}
