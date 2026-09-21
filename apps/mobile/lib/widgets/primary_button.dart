import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.95, upperBound: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        if (!widget.isLoading && widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [Color(0xFFFACC15), Color(0xFFEAB308)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: widget.isLoading 
              ? const CircularProgressIndicator.adaptive(backgroundColor: Colors.white)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.black),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
