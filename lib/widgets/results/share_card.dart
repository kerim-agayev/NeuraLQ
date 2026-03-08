import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../constants/celebrities.dart';
import '../../widgets/ui/neon_button.dart';

class ShareCard extends StatelessWidget {
  final int iqScore;
  final String celebrityKey;
  final String? certificateUrl;
  final VoidCallback onGoHome;

  const ShareCard({
    super.key,
    required this.iqScore,
    required this.celebrityKey,
    this.certificateUrl,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final secondaryColor =
        isDark ? CyberpunkColors.secondary : CleanColors.secondary;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;

    final celebrity = getCelebrityByKey(celebrityKey);

    return Column(
      children: [
        // Share button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'I scored $iqScore on NeuralQ IQ Test! I think like ${celebrity.label} ${celebrity.emoji}. Can you beat me?',
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
              label: const Text('Download Certificate'),
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
            text: 'Take Another Test',
            onPressed: onGoHome,
            primary: primaryColor,
            secondary: secondaryColor,
          ),
        ),
      ],
    );
  }
}
