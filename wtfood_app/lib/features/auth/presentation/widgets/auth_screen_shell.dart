import 'package:flutter/material.dart';

import 'package:wtfood_app/core/theme.dart';

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
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.authBackground,
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
    final palette = context.appPalette;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -56,
            right: -48,
            child: _AccentCircle(size: 128, color: palette.authGreenAccent),
          ),
          Positioned(
            top: -34,
            right: 38,
            child: _AccentCircle(size: 102, color: palette.authOrangeAccent),
          ),
          Positioned(
            bottom: -46,
            left: 34,
            child: _AccentCircle(size: 110, color: palette.authOrangeAccent),
          ),
          Positioned(
            bottom: -62,
            left: -20,
            child: _AccentCircle(size: 136, color: palette.authGreenAccent),
          ),
        ],
      ),
    );
  }
}

class _AccentCircle extends StatelessWidget {
  const _AccentCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
