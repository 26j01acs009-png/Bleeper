import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/supabase/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
      }
      setState(() {
        _resendCooldown -= 1;
      });
    });
  }

  Future<void> _onVerify() async {
    final auth = context.read<AuthProvider>();
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      return;
    }
    final email = auth.pendingEmail;
    if (email == null || email.isEmpty) return;

    try {
      await auth.verifyEmailOtp(email: email, token: code);
    } catch (e) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _onResend() async {
    if (_resendCooldown > 0) return;
    final auth = context.read<AuthProvider>();
    await auth.resendVerificationOtp();
    _startResendCooldown();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 24),
                Text(
                  'Verify email',
                  style: context.h2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingSm),
                Text(
                  'Enter the 6-digit code sent to\n${auth.pendingEmail ?? "your email"}',
                  style: context.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingXxl + 16),
                if (auth.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      auth.errorMessage!,
                      style: TextStyle(color: context.error, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  children: List.generate(6, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 5 ? 8.0 : 0.0),
                        child: TextFormField(
                          controller: _codeControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          obscureText: false,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: context.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: context.accent,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: context.error,
                                width: 2,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: context.spacingXxl + 16),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final code = _codeControllers.map((c) => c.text).join();
                    final canVerify = code.length == 6 && !auth.isLoading;
                    return BleeperButton(
                      label: 'Verify',
                      isLoading: auth.isLoading,
                      onPressed: canVerify ? _onVerify : null,
                    );
                  },
                ),
                SizedBox(height: context.spacingMd),
                TextButton(
                  onPressed: _resendCooldown > 0 ? null : _onResend,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend code in $_resendCooldown'
                        : 'Resend code',
                    style: context.bodyMedium.copyWith(
                      color: _resendCooldown > 0
                          ? context.textTertiary
                          : context.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: context.spacingMd),
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
    );
  }
}
