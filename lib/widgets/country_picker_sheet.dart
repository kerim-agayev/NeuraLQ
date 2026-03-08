import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../constants/countries.dart';

class CountryPickerSheet extends StatefulWidget {
  final String? selectedCode;

  const CountryPickerSheet({super.key, this.selectedCode});

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final _searchController = TextEditingController();
  List<Country> _filtered = countries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = countries;
      } else {
        _filtered = countries
            .where((c) =>
                c.name.toLowerCase().contains(query) ||
                c.code.toLowerCase().contains(query))
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
    final bgColor = isDark ? CyberpunkColors.surface : CleanColors.surface;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final borderColor = isDark ? CyberpunkColors.border : CleanColors.border;
    final surfaceColor =
        isDark ? CyberpunkColors.surfaceLight : CleanColors.surfaceLight;
    final sheetHeight = MediaQuery.of(context).size.height * 0.65;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Select Country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: textSecondary, size: 20),
                filled: true,
                fillColor: surfaceColor,
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Country list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final country = _filtered[index];
                final isSelected = widget.selectedCode == country.code;

                return ListTile(
                  onTap: () => Navigator.pop(context, country),
                  leading: Text(country.flag,
                      style: const TextStyle(fontSize: 24)),
                  title: AutoSizeText(
                    country.name,
                    maxLines: 1,
                    minFontSize: 12,
                    style: TextStyle(
                      color: isSelected ? primaryColor : textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: primaryColor, size: 20)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: isSelected
                      ? primaryColor.withValues(alpha: 0.1)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
