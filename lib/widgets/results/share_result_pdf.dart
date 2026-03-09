import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/celebrities.dart';
import '../../models/result.dart';

pw.Document generateSharePDF(TestResult result) {
  final doc = pw.Document();
  final celebrity = getCelebrityByKey(result.celebrityMatch);

  final cyan = PdfColor.fromHex('#00f5ff');
  final darkBg = PdfColor.fromHex('#0a0a0f');
  final surfaceBg = PdfColor.fromHex('#1a1a2e');
  final grey400 = PdfColor.fromHex('#9ca3af');
  final grey600 = PdfColor.fromHex('#6b7280');

  doc.addPage(pw.Page(
    pageFormat: const PdfPageFormat(1080, 1080),
    build: (context) => pw.Container(
      width: 1080,
      height: 1080,
      color: darkBg,
      padding: const pw.EdgeInsets.all(60),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          // Logo
          pw.Text(
            'NeuralQ',
            style: pw.TextStyle(
              color: cyan,
              fontSize: 52,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'IQ TEST RESULTS',
            style: pw.TextStyle(
              color: grey400,
              fontSize: 16,
              letterSpacing: 4,
            ),
          ),
          pw.SizedBox(height: 40),

          // IQ Score
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 60, vertical: 30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: cyan, width: 2),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  '${result.iqScore}',
                  style: pw.TextStyle(
                    color: cyan,
                    fontSize: 100,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'IQ SCORE',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Celebrity Match
          pw.Text(
            'You think like ${celebrity.label}',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 22,
            ),
          ),
          pw.SizedBox(height: 35),

          // Category Bars (no MEMORY)
          _categoryBar('Spatial', result.spatialPercentile, cyan),
          pw.SizedBox(height: 12),
          _categoryBar(
              'Logic', result.logicPercentile, PdfColor.fromHex('#a855f7')),
          pw.SizedBox(height: 12),
          if (result.verbalPercentile != null &&
              result.verbalPercentile! > 0) ...[
            _categoryBar(
                'Verbal', result.verbalPercentile!, PdfColor.fromHex('#f59e0b')),
            pw.SizedBox(height: 12),
          ],
          _categoryBar(
              'Speed', result.speedPercentile, PdfColor.fromHex('#10b981')),
          pw.SizedBox(height: 30),

          // Ranks
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: pw.BoxDecoration(
              color: surfaceBg,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (result.globalRank != null) ...[
                  pw.Text(
                    'Global #${result.globalRank}',
                    style: pw.TextStyle(color: grey400, fontSize: 16),
                  ),
                  if (result.countryRank != null)
                    pw.Text(
                      '   |   ',
                      style: pw.TextStyle(color: grey600, fontSize: 16),
                    ),
                ],
                if (result.countryRank != null)
                  pw.Text(
                    'Country #${result.countryRank}',
                    style: pw.TextStyle(color: grey400, fontSize: 16),
                  ),
                if (result.cognitiveAge > 0) ...[
                  pw.Text(
                    '   |   ',
                    style: pw.TextStyle(color: grey600, fontSize: 16),
                  ),
                  pw.Text(
                    'Brain Age: ${result.cognitiveAge}',
                    style: pw.TextStyle(color: grey400, fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 40),

          // Footer
          pw.Text(
            'Take your test at neuralq.app',
            style: pw.TextStyle(
              color: grey600,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ),
  ));

  return doc;
}

pw.Widget _categoryBar(String label, double pct, PdfColor color) {
  final grey600 = PdfColor.fromHex('#6b7280');
  final barBg = PdfColor.fromHex('#1a1a2e');
  // Total bar area: 1080 - 120 (padding) - 80 (label) - 12 (gap) - 50 (pct) = 818
  final barWidth = 818.0;
  final fillWidth = barWidth * (pct / 100).clamp(0.0, 1.0);

  return pw.Row(
    children: [
      pw.SizedBox(
        width: 80,
        child: pw.Text(
          label,
          style: pw.TextStyle(color: PdfColors.white, fontSize: 16),
        ),
      ),
      pw.Expanded(
        child: pw.Stack(
          children: [
            pw.Container(
              height: 14,
              decoration: pw.BoxDecoration(
                color: barBg,
                borderRadius: pw.BorderRadius.circular(7),
              ),
            ),
            pw.Container(
              height: 14,
              width: fillWidth,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(width: 12),
      pw.SizedBox(
        width: 50,
        child: pw.Text(
          '${pct.toInt()}%',
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            color: grey600,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
