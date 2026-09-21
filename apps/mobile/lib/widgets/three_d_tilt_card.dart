import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A hardware-accelerated 3D perspective tilt card.
/// Responds to touch pan / pointer hover with Matrix4 rotateX/rotateY transforms.
/// Includes a dynamic specular glare overlay that tracks the tilt angle.
class ThreeDTiltCard extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double maxTiltDeg;
  final Color glowColor;
  final double borderRadius;
  final Color borderColor;
  final List<Color> glassGradient;

  const ThreeDTiltCard({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = 180,
    this.maxTiltDeg = 10.0,
    this.glowColor = const Color(0xFF10B981),
    this.borderRadius = 20,
    this.borderColor = const Color(0x4010B981),
    this.glassGradient = const [Color(0x2210B981), Color(0x110D1F1A)],
  });

  @override
  State<ThreeDTiltCard> createState() => _ThreeDTiltCardState();
}

class _ThreeDTiltCardState extends State<ThreeDTiltCard>
    with SingleTickerProviderStateMixin {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _scale = 1.0;
  bool _isPressed = false;

  late AnimationController _returnCtrl;
  Animation<double>? _returnX;
  Animation<double>? _returnY;
  Animation<double>? _returnScale;

  @override
  void initState() {
    super.initState();
    _returnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _returnCtrl.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;
    final local = box.globalToLocal(d.globalPosition);
    final nx = ((local.dx / size.width) - 0.5) * 2.0;
    final ny = ((local.dy / size.height) - 0.5) * 2.0;
    _returnCtrl.stop();
    setState(() {
      _tiltY = nx.clamp(-1.0, 1.0);
      _tiltX = -ny.clamp(-1.0, 1.0);
      _scale = 1.03;
      _isPressed = true;
    });
  }

  void _onPanEnd(DragEndDetails _) => _returnToFlat();
  void _onPanCancel() => _returnToFlat();

  void _onHoverMove(PointerEvent e) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;
    final topLeft = box.localToGlobal(Offset.zero);
    final rel = e.position - topLeft;
    final nx = ((rel.dx / size.width) - 0.5) * 2.0;
    final ny = ((rel.dy / size.height) - 0.5) * 2.0;
    _returnCtrl.stop();
    setState(() {
      _tiltY = nx.clamp(-1.0, 1.0);
      _tiltX = -ny.clamp(-1.0, 1.0);
      _scale = 1.015;
    });
  }

  void _onHoverExit(PointerEvent _) => _returnToFlat();

  void _returnToFlat() {
    final fromX = _tiltX;
    final fromY = _tiltY;
    final fromScale = _scale;
    _returnCtrl.reset();
    _returnX = Tween<double>(begin: fromX, end: 0.0).animate(
        CurvedAnimation(parent: _returnCtrl, curve: Curves.easeOutBack));
    _returnY = Tween<double>(begin: fromY, end: 0.0).animate(
        CurvedAnimation(parent: _returnCtrl, curve: Curves.easeOutBack));
    _returnScale = Tween<double>(begin: fromScale, end: 1.0).animate(
        CurvedAnimation(parent: _returnCtrl, curve: Curves.easeOutCubic));
    _returnCtrl.addListener(() {
      if (mounted) {
        setState(() {
          _tiltX = _returnX!.value;
          _tiltY = _returnY!.value;
          _scale = _returnScale!.value;
        });
      }
    });
    _returnCtrl.forward().then((_) {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  Matrix4 get _matrix {
    final maxRad = widget.maxTiltDeg * math.pi / 180.0;
    return Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateX(_tiltX * maxRad)
      ..rotateY(_tiltY * maxRad)
      ..scale(_scale);
  }

  Alignment get _glareAlignment =>
      Alignment(-_tiltY * 0.8, -_tiltX * 0.8);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHoverMove,
      onExit: _onHoverExit,
      cursor: SystemMouseCursors.basic,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onPanCancel: _onPanCancel,
        child: Transform(
          transform: _matrix,
          alignment: FractionalOffset.center,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor
                      .withValues(alpha: _isPressed ? 0.35 : 0.20),
                  blurRadius: _isPressed ? 30 : 18,
                  spreadRadius: _isPressed ? 2 : -2,
                  offset: Offset(_tiltY * 6, -_tiltX * 6),
                ),
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xF2101010),
                          ...widget.glassGradient,
                          const Color(0xF2070707),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: widget.borderColor,
                        width: 1.2,
                      ),
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                  widget.child,
                  // Specular glare
                  IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        gradient: RadialGradient(
                          center: _glareAlignment,
                          radius: 1.0,
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
