import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../data/profile_provider.dart';
import '../../domain/models/profile_model.dart';

class SetupNameScreen extends StatefulWidget {
  const SetupNameScreen({super.key});

  @override
  State<SetupNameScreen> createState() => _SetupNameScreenState();
}

class _SetupNameScreenState extends State<SetupNameScreen> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _controller = TextEditingController(text: profile?.displayName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final current = context.read<ProfileProvider>().profile ??
          ProfileModel(
            id: context.read<AuthProvider>().user!.id,
            email: context.read<AuthProvider>().user?.email,
          );
      final updated = ProfileModel(
        id: current.id,
        email: current.email,
        username: current.username,
        displayName: trimmed,
        avatarUrl: current.avatarUrl,
        bio: current.bio,
        phone: current.phone,
        dateOfBirth: current.dateOfBirth,
        gender: current.gender,
        location: current.location,
        website: current.website,
      );
      await context.read<ProfileProvider>().updateProfile(updated);
      if (!mounted) return;
      context.go('/setup/gender-dob');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save name: ${e.toString()}')),
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
                      "What's your name?",
                      style: context.h2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacingMd),
                    Text(
                      'This will appear on your profile.',
                      style: context.bodyMedium.copyWith(color: context.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacingXl + 12),
                    BleeperInput(
                      controller: _controller,
                      hintText: 'Display name',
                      prefixIcon: Icons.person_outline,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: BleeperLoadingIndicator(size: 40),
                )),
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
