import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ui/neon_button.dart';
import '../../widgets/ui/neon_text.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _googleLogin() async {
    await ref.read(authProvider.notifier).googleAuth();
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
                      style: TextStyle(fontSize: screenHeight * 0.06),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // NeuralQ title
                    NeonText(
                      'NeuralQ',
                      fontSize: screenHeight * 0.035,
                      color: primaryColor,
                      glow: isDark,
                    ),
                    SizedBox(height: screenHeight * 0.008),

                    AutoSizeText(
                      'Sign in to continue',
                      maxLines: 1,
                      minFontSize: 12,
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: textSecondary),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: textSecondary, size: 20),
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
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!val.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Password',
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
                    SizedBox(height: screenHeight * 0.03),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: NeonButton(
                        text: 'Sign In',
                        onPressed: _login,
                        isLoading: auth.isLoading,
                        primary: primaryColor,
                        secondary: isDark
                            ? CyberpunkColors.secondary
                            : CleanColors.secondary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

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
                    SizedBox(height: screenHeight * 0.025),

                    // Google button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: auth.isLoading ? null : _googleLogin,
                        icon: Text('\u{1F310}',
                            style: const TextStyle(fontSize: 20)),
                        label: const Text('Continue with Google'),
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
                    SizedBox(height: screenHeight * 0.04),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          "Don't have an account? ",
                          maxLines: 1,
                          minFontSize: 11,
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: AutoSizeText(
                            'Sign Up',
                            maxLines: 1,
                            minFontSize: 11,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
}
