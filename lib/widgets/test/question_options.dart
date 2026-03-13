import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/question.dart';

class QuestionOptions extends StatelessWidget {
  final List<QuestionOption> options;
  final int? selectedAnswer;
  final int? correctAnswer;
  final bool showFeedback;
  final bool enabled;
  final ValueChanged<int> onSelect;

  const QuestionOptions({
    super.key,
    required this.options,
    this.selectedAnswer,
    this.correctAnswer,
    this.showFeedback = false,
    this.enabled = true,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = options.any((o) => o.imageUrl != null);

    if (hasImages) {
      return _buildImageGrid(context);
    }
    return _buildTextList(context);
  }

  Widget _buildTextList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surfaceLight;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final successColor =
        isDark ? CyberpunkColors.success : CleanColors.success;
    final errorColor = isDark ? CyberpunkColors.error : CleanColors.error;

    return Column(
      children: List.generate(options.length, (index) {
        final isSelected = selectedAnswer == index;
        final isCorrect = showFeedback && correctAnswer == index;
        final isWrong = showFeedback && isSelected && correctAnswer != index;

        Color bgColor = surfaceColor;
        Color border = borderColor;
        if (isCorrect) {
          bgColor = successColor.withValues(alpha: 0.15);
          border = successColor;
        } else if (isWrong) {
          bgColor = errorColor.withValues(alpha: 0.15);
          border = errorColor;
        } else if (isSelected) {
          bgColor = primaryColor.withValues(alpha: 0.15);
          border = primaryColor;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: enabled ? () => onSelect(index) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: isSelected || isCorrect || isWrong ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected || isCorrect
                          ? (isCorrect ? successColor : isWrong ? errorColor : primaryColor)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected || isCorrect
                            ? Colors.transparent
                            : borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected || isCorrect
                              ? Colors.white
                              : textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AutoSizeText(
                      options[index].text,
                      maxLines: 3,
                      minFontSize: 11,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Icon(Icons.check_circle, color: successColor, size: 20),
                  if (isWrong)
                    Icon(Icons.cancel, color: errorColor, size: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surfaceLight;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final successColor =
        isDark ? CyberpunkColors.success : CleanColors.success;
    final errorColor = isDark ? CyberpunkColors.error : CleanColors.error;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedAnswer == index;
        final isCorrect = showFeedback && correctAnswer == index;
        final isWrong = showFeedback && isSelected && correctAnswer != index;

        Color bgColor = surfaceColor;
        Color border = borderColor;
        if (isCorrect) {
          bgColor = successColor.withValues(alpha: 0.15);
          border = successColor;
        } else if (isWrong) {
          bgColor = errorColor.withValues(alpha: 0.15);
          border = errorColor;
        } else if (isSelected) {
          bgColor = primaryColor.withValues(alpha: 0.15);
          border = primaryColor;
        }

        return GestureDetector(
          onTap: enabled ? () => onSelect(index) : null,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: isSelected || isCorrect || isWrong ? 2 : 1),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11)),
                    child: option.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: option.imageUrl!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorWidget: (_, _, _) => Center(
                              child: AutoSizeText(
                                option.text,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                        : Center(
                            child: AutoSizeText(
                              option.text,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                  ),
                ),
                // A, B, C, D label
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? successColor.withValues(alpha: 0.2)
                        : isWrong
                            ? errorColor.withValues(alpha: 0.2)
                            : isSelected
                                ? primaryColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(11)),
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isCorrect
                          ? successColor
                          : isWrong
                              ? errorColor
                              : isSelected
                                  ? primaryColor
                                  : textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
