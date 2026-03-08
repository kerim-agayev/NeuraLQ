import 'package:flutter/material.dart';

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final int? maxLines;
  final bool glow;

  const NeonText(
    this.text, {
    super.key,
    this.fontSize = 32,
    this.fontWeight = FontWeight.w700,
    this.color = const Color(0xFF00F5FF),
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 2,
        shadows: glow
            ? [
                Shadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 12,
                ),
                Shadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 24,
                ),
              ]
            : null,
      ),
    );
  }
}
