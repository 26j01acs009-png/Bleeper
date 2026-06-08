import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../data/profile_provider.dart';
import '../../domain/models/profile_model.dart';

class SetupUsernameScreen extends StatefulWidget {
  const SetupUsernameScreen({super.key});

  @override
  State<SetupUsernameScreen> createState() => _SetupUsernameScreenState();
}

class _SetupUsernameScreenState extends State<SetupUsernameScreen> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  static const _minChars = 4;
  static const _maxChars = 32;
  static final _regex = RegExp(r'^[a-zA-Z0-9_]+$');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AuthProvider>().user?.email?.split('@').first ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<ProfileProvider>().isProfileComplete) {
        context.go('/home');
      }
    });
  }

  String? _validate(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Username is required';
    final username = raw.startsWith('@') ? raw.substring(1) : raw;
    if (username.length < _minChars) return 'At least $_minChars characters';
    if (username.length > _maxChars) return 'No more than $_maxChars characters';
    if (!_regex.hasMatch(username)) return 'Only letters, numbers, and underscores';
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_validate(_controller.text) != null) return;
    final trimmed = _controller.text.trim();
    final username = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;

    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthProvider>().user!.id;
      await context.read<ProfileProvider>().updateProfile(
        ProfileModel(
          id: userId,
          email: context.read<AuthProvider>().user?.email,
          username: username,
        ),
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save username: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 24),
                  Text(
                    'Choose your username',
                    style: context.h2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacingMd),
                  Text(
                    'This is how others will find you on Bleeper.',
                    style: context.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacingXl + 12),
                  BleeperInput(
                    controller: _controller,
                    hintText: 'username',
                    prefixIcon: Icons.alternate_email,
                    maxLines: 1,
                    onChanged: (_) {},
                    validator: _validate,
                  ),
                  SizedBox(height: context.spacingXxl + 8),
                  BleeperButton(
                    label: 'Continue',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _continue,
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
