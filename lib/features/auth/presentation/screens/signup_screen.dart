import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../shared/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isFormValid {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    return email.isNotEmpty && 
           email.contains('@') && 
           password.isNotEmpty && 
           password.length >= 6 && 
           confirmPassword == password &&
           _acceptedTerms;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _onSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<AuthProvider>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final auth = context.read<AuthProvider>();
      if (auth.status == AuthStatus.unauthenticated && auth.pendingEmail != null) {
        if (mounted) context.go('/email-verification');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 24),
                  Text(
                    'Create account',
                    style: context.h2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacingXxl + 16),
                  BleeperInput(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: context.spacingMd),
                  BleeperInput(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: context.spacingMd),
                  BleeperInput(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: context.spacingLg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(
                          () => _acceptedTerms = !_acceptedTerms,
                        ),
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _acceptedTerms
                                  ? context.accent
                                  : context.textTertiary,
                              width: 2,
                            ),
                            color: _acceptedTerms
                                ? context.accent
                                : Colors.transparent,
                          ),
                          child: _acceptedTerms
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: context.bodySmall.copyWith(
                              color: context.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacingXxl + 16),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return BleeperButton(
                        label: 'Continue',
                        isLoading: auth.isLoading,
                        onPressed: _isFormValid ? _onSignUp : null,
                      );
                    },
                  ),
                  if (context.watch<AuthProvider>().errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.watch<AuthProvider>().errorMessage!,
                        style: TextStyle(
                          color: context.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(height: context.spacingMd),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Already have an account? Login',
                      style: context.bodyMedium.copyWith(
                        color: context.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}