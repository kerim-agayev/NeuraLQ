import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../constants/celebrities.dart';
import '../../providers/test_provider.dart';
import '../../widgets/ui/neon_button.dart';
import '../../widgets/ui/neon_text.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iqAnimation;

  @override
  void initState() {
    super.initState();
    final result = ref.read(testProvider).result;
    final targetIq = result?.iqScore.toDouble() ?? 100.0;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _iqAnimation = Tween<double>(begin: 0, end: targetIq).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final secondaryColor =
        isDark ? CyberpunkColors.secondary : CleanColors.secondary;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;

    final result = ref.watch(testProvider).result;

    if (result == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text('No result available',
              style: TextStyle(color: textColor)),
        ),
      );
    }

    final celebrity = getCelebrityByKey(result.celebrityMatch);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(testProvider.notifier).reset();
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              children: [
                // IQ Reveal
                AnimatedBuilder(
                  animation: _iqAnimation,
                  builder: (context, _) {
                    return Column(
                      children: [
                        NeonText(
                          'Your IQ Score',
                          fontSize: 18,
                          color: textSecondary,
                          glow: false,
                        ),
                        const SizedBox(height: 8),
                        NeonText(
                          '${_iqAnimation.value.toInt()}',
                          fontSize: 64,
                          color: primaryColor,
                          glow: isDark,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Spider Chart
                SizedBox(
                  height: 220,
                  child: _SpiderChart(
                    spatialPct: result.spatialPercentile,
                    logicPct: result.logicPercentile,
                    verbalPct: result.verbalPercentile ?? 0,
                    memoryPct: result.memoryPercentile,
                    speedPct: result.speedPercentile,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    textColor: textSecondary,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Celebrity Match
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'You think like...',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(celebrity.emoji,
                          style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      AutoSizeText(
                        celebrity.label,
                        maxLines: 1,
                        minFontSize: 16,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cognitive Age + Ranks
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'Cognitive Age',
                        value: '${result.cognitiveAge}',
                        emoji: '\u{1F9D1}',
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textSecondary: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: 'Global Rank',
                        value: result.globalRank != null
                            ? '#${result.globalRank}'
                            : '-',
                        emoji: '\u{1F30D}',
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textSecondary: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category Breakdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CategoryBar(
                          label: '\u{1F4D0} Spatial',
                          pct: result.spatialPercentile,
                          color: primaryColor,
                          textColor: textSecondary,
                          bgColor: borderColor),
                      const SizedBox(height: 8),
                      _CategoryBar(
                          label: '\u{1F9E9} Logic',
                          pct: result.logicPercentile,
                          color: secondaryColor,
                          textColor: textSecondary,
                          bgColor: borderColor),
                      if (result.verbalPercentile != null) ...[
                        const SizedBox(height: 8),
                        _CategoryBar(
                            label: '\u{1F4DD} Verbal',
                            pct: result.verbalPercentile!,
                            color: isDark
                                ? CyberpunkColors.accent
                                : CleanColors.accent,
                            textColor: textSecondary,
                            bgColor: borderColor),
                      ],
                      const SizedBox(height: 8),
                      _CategoryBar(
                          label: '\u{1F9E0} Memory',
                          pct: result.memoryPercentile,
                          color: isDark
                              ? CyberpunkColors.warning
                              : CleanColors.warning,
                          textColor: textSecondary,
                          bgColor: borderColor),
                      const SizedBox(height: 8),
                      _CategoryBar(
                          label: '\u{26A1} Speed',
                          pct: result.speedPercentile,
                          color: isDark
                              ? CyberpunkColors.success
                              : CleanColors.success,
                          textColor: textSecondary,
                          bgColor: borderColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Share button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                              'I scored ${result.iqScore} on NeuralQ IQ Test! I think like ${celebrity.label} ${celebrity.emoji}. Can you beat me?',
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Result'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Home button
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'Back to Home',
                    onPressed: () {
                      ref.read(testProvider.notifier).reset();
                      context.go('/home');
                    },
                    primary: primaryColor,
                    secondary: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Spider Chart ──
class _SpiderChart extends StatelessWidget {
  final double spatialPct;
  final double logicPct;
  final double verbalPct;
  final double memoryPct;
  final double speedPct;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color borderColor;

  const _SpiderChart({
    required this.spatialPct,
    required this.logicPct,
    required this.verbalPct,
    required this.memoryPct,
    required this.speedPct,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 220),
      painter: _SpiderChartPainter(
        values: [
          spatialPct / 100,
          logicPct / 100,
          verbalPct / 100,
          memoryPct / 100,
          speedPct / 100,
        ],
        labels: ['Spatial', 'Logic', 'Verbal', 'Memory', 'Speed'],
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        gridColor: borderColor,
      ),
    );
  }
}

class _SpiderChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color gridColor;

  _SpiderChartPainter({
    required this.values,
    required this.labels,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final sides = values.length;
    final angle = (2 * math.pi) / sides;

    // Draw grid
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int level = 1; level <= 4; level++) {
      final r = radius * (level / 4);
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final x = center.dx + r * math.cos(angle * i - math.pi / 2);
        final y = center.dy + r * math.sin(angle * i - math.pi / 2);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axes
    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw data
    final dataPath = Path();
    for (int i = 0; i < sides; i++) {
      final val = values[i].clamp(0.0, 1.0);
      final r = radius * val;
      final x = center.dx + r * math.cos(angle * i - math.pi / 2);
      final y = center.dy + r * math.sin(angle * i - math.pi / 2);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Fill
    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(dataPath, strokePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < sides; i++) {
      final val = values[i].clamp(0.0, 1.0);
      final r = radius * val;
      final x = center.dx + r * math.cos(angle * i - math.pi / 2);
      final y = center.dy + r * math.sin(angle * i - math.pi / 2);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Draw labels
    for (int i = 0; i < sides; i++) {
      final labelR = radius + 20;
      final x = center.dx + labelR * math.cos(angle * i - math.pi / 2);
      final y = center.dy + labelR * math.sin(angle * i - math.pi / 2);

      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(color: textColor, fontSize: 11),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Info Card ──
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color textSecondary;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          AutoSizeText(
            value,
            maxLines: 1,
            minFontSize: 16,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          AutoSizeText(
            label,
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Category Bar ──
class _CategoryBar extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  final Color textColor;
  final Color bgColor;

  const _CategoryBar({
    required this.label,
    required this.pct,
    required this.color,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: AutoSizeText(
            label,
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (pct / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${pct.toInt()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
