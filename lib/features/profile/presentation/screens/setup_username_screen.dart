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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text:
          '@${context.read<AuthProvider>().user?.email?.split('@').first ?? ''}',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    final username = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    if (username.isEmpty) return;

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
      context.go('/setup/name');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: BleeperLoadingIndicator(size: 40),
                  ),
                ),
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
    );
  }
}
