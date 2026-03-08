import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../constants/languages.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class LanguagePickerModal extends ConsumerStatefulWidget {
  final String? selectedCode;

  const LanguagePickerModal({super.key, this.selectedCode});

  @override
  ConsumerState<LanguagePickerModal> createState() =>
      _LanguagePickerModalState();
}

class _LanguagePickerModalState extends ConsumerState<LanguagePickerModal> {
  final _searchController = TextEditingController();
  List<AppLanguage> _filtered = appLanguages;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = appLanguages;
      } else {
        _filtered = appLanguages
            .where((l) =>
                l.name.toLowerCase().contains(query) ||
                l.code.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CyberpunkColors.surface : CleanColors.surface;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;
    final surfaceLight = isDark
        ? CyberpunkColors.surfaceLight
        : CleanColors.surfaceLight;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.65,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'profile.selectLanguage'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'profile.searchLanguage'.tr(),
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.search, color: textSecondary),
                filled: true,
                fillColor: surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Language list
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final lang = _filtered[index];
                final isSelected = lang.code == widget.selectedCode;

                return ListTile(
                  leading:
                      Text(lang.flag, style: const TextStyle(fontSize: 24)),
                  title: AutoSizeText(
                    lang.name,
                    maxLines: 1,
                    minFontSize: 12,
                    style: TextStyle(
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    lang.code.toUpperCase(),
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: primaryColor)
                      : null,
                  onTap: () {
                    context.setLocale(Locale(lang.code));
                    ref
                        .read(settingsProvider.notifier)
                        .setLanguage(lang.code);
                    ref
                        .read(authProvider.notifier)
                        .updateProfile(language: lang.code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
