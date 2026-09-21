import 'package:flutter/material.dart';

/// Deep Dark Pitch Black Background (#000000) as requested.
class AmbientBackground extends StatelessWidget {
  final Widget child;
  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF000000),
      child: child,
    );
  }
}
