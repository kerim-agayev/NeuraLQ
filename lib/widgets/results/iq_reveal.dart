import 'package:flutter/material.dart';
import '../../config/theme.dart';

class IqReveal extends StatefulWidget {
  final int targetIq;

  const IqReveal({super.key, required this.targetIq});

  @override
  State<IqReveal> createState() => _IqRevealState();
}

class _IqRevealState extends State<IqReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _countAnimation = Tween<double>(
      begin: 0,
      end: widget.targetIq.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _iqColor(int iq, bool isDark) {
    if (iq >= 140) {
      return isDark ? CyberpunkColors.accent : CleanColors.accent;
    } else if (iq >= 120) {
      return isDark ? CyberpunkColors.success : CleanColors.success;
    } else if (iq >= 100) {
      return isDark ? CyberpunkColors.primary : CleanColors.primary;
    } else if (iq >= 85) {
      return isDark ? CyberpunkColors.warning : CleanColors.warning;
    } else {
      return isDark ? CyberpunkColors.error : CleanColors.error;
    }
  }

  String _iqLabel(int iq) {
    if (iq >= 160) return 'Extraordinary';
    if (iq >= 140) return 'Genius';
    if (iq >= 130) return 'Gifted';
    if (iq >= 120) return 'Superior';
    if (iq >= 110) return 'Above Average';
    if (iq >= 90) return 'Average';
    if (iq >= 80) return 'Below Average';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final iqColor = _iqColor(widget.targetIq, isDark);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentIq = _countAnimation.value.toInt();
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your IQ Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentIq',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: iqColor,
                    letterSpacing: 2,
                    shadows: isDark
                        ? [
                            Shadow(
                              color: iqColor.withValues(alpha: 0.6),
                              blurRadius: 20,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: iqColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: iqColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _iqLabel(widget.targetIq),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: iqColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
