import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../constants/celebrities.dart';
import '../../models/result.dart';
import '../../widgets/ui/neon_button.dart';
import 'share_result_pdf.dart';

class ShareCard extends StatelessWidget {
  final int iqScore;
  final String celebrityKey;
  final String? certificateUrl;
  final VoidCallback onGoHome;
  final TestResult? result;

  const ShareCard({
    super.key,
    required this.iqScore,
    required this.celebrityKey,
    this.certificateUrl,
    required this.onGoHome,
    this.result,
  });

  Future<void> _sharePdf() async {
    if (result == null) return;
    final doc = generateSharePDF(result!);
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'neuralq-iq-${result!.iqScore}.pdf',
    );
  }

  void _shareText() {
    final celebrity = getCelebrityByKey(celebrityKey);
    SharePlus.instance.share(
      ShareParams(
        text:
            'I scored $iqScore on NeuralQ IQ Test! I think like ${celebrity.label} ${celebrity.emoji}. Can you beat me?',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final secondaryColor =
        isDark ? CyberpunkColors.secondary : CleanColors.secondary;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    return Column(
      children: [
        // Share as PDF
        if (result != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _sharePdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text('result.sharePdf'.tr()),
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

        // Share as text
        if (result != null) const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareText,
            icon: const Icon(Icons.share),
            label: Text('result.shareText'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: result != null ? textSecondary : primaryColor,
              side: BorderSide(
                  color: result != null ? textSecondary : primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Certificate download
        if (certificateUrl != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(certificateUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.download),
              label: Text('result.downloadCertificate'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: textSecondary,
                side: BorderSide(color: textSecondary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Take another / Home
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'result.takeAnother'.tr(),
            onPressed: onGoHome,
            primary: primaryColor,
            secondary: secondaryColor,
          ),
        ),
      ],
    );
  }
}
