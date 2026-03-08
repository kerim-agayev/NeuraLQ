import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class BrainLoader extends StatefulWidget {
  final String message;
  final bool overlay;

  const BrainLoader({
    super.key,
    required this.message,
    this.overlay = false,
  });

  @override
  State<BrainLoader> createState() => _BrainLoaderState();
}

class _BrainLoaderState extends State<BrainLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = (size.width * 0.28).clamp(80.0, 120.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final bgColor = isDark ? CyberpunkColors.background : CleanColors.background;

    return Container(
      color: bgColor.withValues(alpha: widget.overlay ? 0.5 : 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.95 + (_controller.value * 0.1),
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\u{1F9E0}',
                          style: TextStyle(fontSize: circleSize * 0.28),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: circleSize * 0.2,
                          height: circleSize * 0.2,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AutoSizeText(
                widget.message,
                maxLines: 2,
                minFontSize: 10,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
