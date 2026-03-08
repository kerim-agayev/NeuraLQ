import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/result.dart';
import '../../services/test_service.dart';
import '../../widgets/results/iq_reveal.dart';
import '../../widgets/results/spider_chart.dart';
import '../../widgets/results/celebrity_match.dart';
import '../../widgets/results/cognitive_age.dart';
import '../../widgets/results/category_breakdown.dart';
import '../../widgets/ui/brain_loader.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String sessionId;

  const HistoryDetailScreen({super.key, required this.sessionId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  TestResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result =
          await TestService.getResult(sessionId: widget.sessionId);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'result.failedToLoad'.tr();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'result.testResult'.tr(),
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? BrainLoader(message: 'result.loadingResult'.tr())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{26A0}\u{FE0F}',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: TextStyle(
                                fontSize: 16, color: textSecondary)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadResult,
                          child: Text('common.retry'.tr()),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      children: [
                        // Mode + Date info
                        if (_result!.mode != null || _result!.completedAt.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                if (_result!.mode != null) ...[
                                  Text(
                                    _result!.mode == 'FULL_ANALYSIS'
                                        ? '\u{1F9E0} ${'test.fullAnalysis'.tr()}'
                                        : '\u{26A1} ${'test.arcade'.tr()}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    '  \u{2022}  ',
                                    style: TextStyle(
                                        color: textSecondary),
                                  ),
                                ],
                                Text(
                                  _formatDate(_result!.completedAt),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // IQ Reveal
                        IqReveal(targetIq: _result!.iqScore),
                        const SizedBox(height: 28),

                        // Spider Chart
                        SpiderChart(
                          spatialPct: _result!.spatialPercentile,
                          logicPct: _result!.logicPercentile,
                          verbalPct: _result!.verbalPercentile,
                          memoryPct: _result!.memoryPercentile,
                          speedPct: _result!.speedPercentile,
                        ),
                        const SizedBox(height: 24),

                        // Celebrity Match
                        CelebrityMatchCard(
                          celebrityKey: _result!.celebrityMatch,
                        ),
                        const SizedBox(height: 16),

                        // Cognitive Age + Ranks
                        CognitiveAgeCard(
                          cognitiveAge: _result!.cognitiveAge,
                          globalRank: _result!.globalRank,
                          countryRank: _result!.countryRank,
                        ),
                        const SizedBox(height: 16),

                        // Category Breakdown
                        CategoryBreakdown(
                          spatialPct: _result!.spatialPercentile,
                          logicPct: _result!.logicPercentile,
                          verbalPct: _result!.verbalPercentile,
                          memoryPct: _result!.memoryPercentile,
                          speedPct: _result!.speedPercentile,
                        ),

                        // Certificate button
                        if (_result!.certificateUrl != null) ...[
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final url = Uri.parse(_result!.certificateUrl!);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.download_rounded),
                              label: Text('result.downloadCertificate'.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? CyberpunkColors.primary
                                    : CleanColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}
