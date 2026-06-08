import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../shared/widgets.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().resetPassword(
            email: _emailController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                    'Reset password',
                    style: context.h2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacingSm),
                  Text(
                    'Enter your email and we\'ll send you a reset link',
                    style: context.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
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
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            auth.errorMessage!,
                            style: TextStyle(
                              color: context.error,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      if (auth.status == AuthStatus.authenticated) {
                        return const SizedBox.shrink();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: context.spacingXxl + 8),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return BleeperButton(
                        label: 'Send reset link',
                        isLoading: auth.isLoading,
                        onPressed: _onResetPassword,
                      );
                    },
                  ),
                  SizedBox(height: context.spacingSm),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Back to login',
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