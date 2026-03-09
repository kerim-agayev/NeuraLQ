import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../constants/countries.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/country_picker_sheet.dart';
import '../../widgets/ui/neon_button.dart';
import '../../widgets/ui/neon_text.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  bool _obscurePassword = true;
  Country? _selectedCountry;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final language = ref.read(settingsProvider).language;
    final age = int.tryParse(_ageController.text.trim());

    await ref.read(authProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          age: age,
          country: _selectedCountry?.code,
          language: language,
        );
  }

  Future<void> _googleRegister() async {
    await ref.read(authProvider.notifier).googleAuth();
  }

  void _showCountryPicker() async {
    final country = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CountryPickerSheet(
        selectedCode: _selectedCountry?.code,
      ),
    );
    if (country != null) {
      setState(() => _selectedCountry = country);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? CyberpunkColors.primary : CleanColors.primary;
    final bgColor =
        isDark ? CyberpunkColors.background : CleanColors.background;
    final textColor = isDark ? CyberpunkColors.text : CleanColors.text;
    final textSecondary =
        isDark ? CyberpunkColors.textSecondary : CleanColors.textSecondary;
    final surfaceColor =
        isDark ? CyberpunkColors.surface : CleanColors.surfaceLight;
    final borderColor =
        isDark ? CyberpunkColors.border : CleanColors.border;

    final auth = ref.watch(authProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null) {
        Fluttertoast.showToast(
          msg: next.error!,
          backgroundColor: isDark ? CyberpunkColors.error : CleanColors.error,
          textColor: Colors.white,
        );
        ref.read(authProvider.notifier).clearError();
      }
      if (next.isAuthenticated && !next.isLoading) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: screenHeight * 0.02,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brain emoji
                    Text(
                      '\u{1F9E0}',
                      style: TextStyle(fontSize: screenHeight * 0.05),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Title
                    NeonText(
                      'auth.register'.tr(),
                      fontSize: screenHeight * 0.028,
                      color: primaryColor,
                      glow: isDark,
                    ),
                    SizedBox(height: screenHeight * 0.005),

                    AutoSizeText(
                      'auth.register'.tr(),
                      maxLines: 1,
                      minFontSize: 11,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Username
                    _buildTextField(
                      controller: _usernameController,
                      hint: 'auth.username'.tr(),
                      icon: Icons.person_outline,
                      textColor: textColor,
                      hintColor: textSecondary,
                      fillColor: surfaceColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (val.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      hint: 'auth.email'.tr(),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textColor: textColor,
                      hintColor: textSecondary,
                      fillColor: surfaceColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!val.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'auth.password'.tr(),
                        hintStyle: TextStyle(color: textSecondary),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: textSecondary, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
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
                          borderSide:
                              BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Password is required';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Age + Country row
                    Row(
                      children: [
                        // Age field
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            controller: _ageController,
                            hint: 'auth.age'.tr(),
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            textColor: textColor,
                            hintColor: textSecondary,
                            fillColor: surfaceColor,
                            borderColor: borderColor,
                            primaryColor: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Country picker
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _showCountryPicker,
                            child: Container(
                              height: 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.public,
                                      color: textSecondary, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AutoSizeText(
                                      _selectedCountry?.name ??
                                          'auth.selectCountry'.tr(),
                                      maxLines: 1,
                                      minFontSize: 10,
                                      style: TextStyle(
                                        color: _selectedCountry != null
                                            ? textColor
                                            : textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (_selectedCountry != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(_selectedCountry!.flag,
                                          style:
                                              const TextStyle(fontSize: 18)),
                                    ),
                                  Icon(Icons.arrow_drop_down,
                                      color: textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: NeonButton(
                        text: 'auth.register'.tr(),
                        onPressed: _register,
                        isLoading: auth.isLoading,
                        primary: primaryColor,
                        secondary: isDark
                            ? CyberpunkColors.secondary
                            : CleanColors.secondary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                            child: Divider(color: borderColor, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 12)),
                        ),
                        Expanded(
                            child: Divider(color: borderColor, thickness: 1)),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Google button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: auth.isLoading ? null : _googleRegister,
                        icon: Text('\u{1F310}',
                            style: const TextStyle(fontSize: 20)),
                        label: Text('auth.continueWithGoogle'.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Login link
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${'auth.alreadyHaveAccount'.tr()} ',
                            style: TextStyle(
                                color: textSecondary, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'auth.login'.tr(),
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
    required Color fillColor,
    required Color borderColor,
    required Color primaryColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(icon, color: hintColor, size: 20),
        filled: true,
        fillColor: fillColor,
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}
