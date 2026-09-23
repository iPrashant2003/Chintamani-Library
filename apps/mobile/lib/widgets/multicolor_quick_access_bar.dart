import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_names.dart';

class QuickActionData {
  final String label;
  final IconData icon;
  final Color accent;       // Muted luxury accent — NO neon
  final List<Color> discGradient;
  final String route;

  const QuickActionData({
    required this.label,
    required this.icon,
    required this.accent,
    required this.discGradient,
    required this.route,
  });
}

class MulticolorQuickAccessBar extends StatelessWidget {
  const MulticolorQuickAccessBar({super.key});

  // 4 actions with premium muted tones — NO neon/bright colors
  static const List<QuickActionData> _actions = [
    QuickActionData(
      label: 'Add Member',
      icon: Icons.person_add_alt_1_rounded,
      accent: Color(0xFFB8922A),          // Deep antique gold
      discGradient: [Color(0xFF2E210A), Color(0xFF191205)],
      route: RouteNames.addMember,
    ),
    QuickActionData(
      label: 'Record Fee',
      icon: Icons.receipt_long_rounded,
      accent: Color(0xFF7B6AA0),           // Muted amethyst
      discGradient: [Color(0xFF1E1630), Color(0xFF100B18)],
      route: RouteNames.recordPayment,
    ),
    QuickActionData(
      label: 'Universal QR',
      icon: Icons.qr_code_2_rounded,
      accent: Color(0xFF8B2F3C),           // Deep wine red
      discGradient: [Color(0xFF2A0D12), Color(0xFF150609)],
      route: RouteNames.qr,
    ),
    QuickActionData(
      label: 'Insights',
      icon: Icons.auto_graph_rounded,
      accent: Color(0xFF4A7AAD),           // Steel blue
      discGradient: [Color(0xFF0D1F38), Color(0xFF07101D)],
      route: RouteNames.insights,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _actions.map((act) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _QuickActionButton(action: act),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final QuickActionData action;
  const _QuickActionButton({required this.action});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 0.05, end: 0.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final act = widget.action;
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) => GestureDetector(
        onTapDown: (_) { HapticFeedback.lightImpact(); _pressCtrl.forward(); },
        onTapUp: (_) { _pressCtrl.reverse(); context.push(act.route); },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  act.accent.withValues(alpha: 0.10),
                  const Color(0xFF0A0812),
                ],
              ),
              border: Border.all(
                color: act.accent.withValues(alpha: 0.22),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: act.accent.withValues(alpha: _pulse.value),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium 3D Luxury Disc — deep gradient, specular rim, no neon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: act.discGradient,
                    ),
                    border: Border.all(
                      color: act.accent.withValues(alpha: 0.40),
                      width: 1.2,
                    ),
                    boxShadow: [
                      // Inner-rim specular highlight (3D depth effect)
                      BoxShadow(
                        color: act.accent.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(-1, -1),
                        spreadRadius: -1,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.60),
                        blurRadius: 6,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(act.icon, color: act.accent, size: 20),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  act.label,
                  style: const TextStyle(
                    color: Color(0xFFD8D8D8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
