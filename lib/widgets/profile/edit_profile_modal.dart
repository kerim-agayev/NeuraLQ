import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/theme.dart';
import '../../constants/countries.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../country_picker_sheet.dart';

class EditProfileModal extends ConsumerStatefulWidget {
  final User user;

  const EditProfileModal({super.key, required this.user});

  @override
  ConsumerState<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<EditProfileModal> {
  late TextEditingController _displayNameController;
  late TextEditingController _ageController;
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName ?? widget.user.username,
    );
    _ageController = TextEditingController(
      text: widget.user.age?.toString() ?? '',
    );
    _selectedCountryCode = widget.user.country;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Country? get _selectedCountry {
    if (_selectedCountryCode == null) return null;
    return countries.cast<Country?>().firstWhere(
          (c) => c!.code == _selectedCountryCode,
          orElse: () => null,
        );
  }

  Future<void> _save() async {
    final name = _displayNameController.text.trim();
    if (name.length < 2) {
      Fluttertoast.showToast(
        msg: 'Name must be at least 2 characters',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    int? age;
    if (_ageController.text.isNotEmpty) {
      age = int.tryParse(_ageController.text);
      if (age == null || age < 5 || age > 100) {
        Fluttertoast.showToast(
          msg: 'Age must be between 5 and 100',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }
    }

    await ref.read(authProvider.notifier).updateProfile(
          displayName: name,
          country: _selectedCountryCode,
          age: age,
        );

    if (!mounted) return;

    final error = ref.read(authProvider).error;
    if (error != null) {
      Fluttertoast.showToast(
        msg: error,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      await ref.read(authProvider.notifier).refreshUser();
      if (mounted) Navigator.pop(context);
    }
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
    final auth = ref.watch(authProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            // Header row: Cancel | Title | Save
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: AutoSizeText(
                    'common.cancel'.tr(),
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(color: textSecondary),
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    'profile.editProfile'.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 12,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: auth.isLoading ? null : _save,
                  child: AutoSizeText(
                    'common.save'.tr(),
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display Name
            TextField(
              controller: _displayNameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'profile.displayName'.tr(),
                labelStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: isDark
                    ? CyberpunkColors.surfaceLight
                    : CleanColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Country
            GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<Country>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CountryPickerSheet(
                    selectedCode: _selectedCountryCode,
                  ),
                );
                if (result != null) {
                  setState(() => _selectedCountryCode = result.code);
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? CyberpunkColors.surfaceLight
                      : CleanColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCountry != null
                            ? '${_selectedCountry!.flag}  ${_selectedCountry!.name}'
                            : 'auth.selectCountry'.tr(),
                        style: TextStyle(
                          color: _selectedCountry != null
                              ? textColor
                              : textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Age
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'auth.age'.tr(),
                labelStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: isDark
                    ? CyberpunkColors.surfaceLight
                    : CleanColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
