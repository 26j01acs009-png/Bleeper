import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../data/profile_provider.dart';
import '../../domain/models/profile_model.dart';

class SetupGenderDobScreen extends StatefulWidget {
  const SetupGenderDobScreen({super.key});

  @override
  State<SetupGenderDobScreen> createState() => _SetupGenderDobScreenState();
}

class _SetupGenderDobScreenState extends State<SetupGenderDobScreen> {
  final _dobController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    if (profile?.dateOfBirth != null) {
      _dobController.text = profile!.dateOfBirth!
          .toIso8601String()
          .split('T')
          .first;
    }
    _selectedGender = profile?.gender;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<ProfileProvider>().isProfileComplete) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final dob = DateTime.tryParse(_dobController.text.trim());
    if (dob != null) {
      final now = DateTime.now();
      final age =
          now.year -
          dob.year -
          (now.month < dob.month ||
                  (now.month == dob.month && now.day < dob.day)
              ? 1
              : 0);
      if (age < 13) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be at least 13 years old.')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final current =
          context.read<ProfileProvider>().profile ??
          ProfileModel(
            id: context.read<AuthProvider>().user!.id,
            email: context.read<AuthProvider>().user?.email,
          );
      final updated = ProfileModel(
        id: current.id,
        email: current.email,
        username: current.username,
        displayName: current.displayName,
        avatarUrl: current.avatarUrl,
        bio: current.bio,
        phone: current.phone,
        dateOfBirth: DateTime.tryParse(_dobController.text.trim()),
        gender: _selectedGender,
        location: current.location,
        website: current.website,
      );
      await context.read<ProfileProvider>().updateProfile(updated);
      if (!mounted) return;
      context.go('/setup/name');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_dobController.text.trim()) ?? DateTime(now.year - 18);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime(1900)) ? initial : DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _dobController.text = picked.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 24),
                Text(
                  'Tell us about yourself',
                  style: context.h2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingXl + 12),
                  BleeperInput(
                    controller: _dobController,
                    hintText: 'YYYY-MM-DD',
                    label: 'Date of birth',
                    prefixIcon: Icons.cake_outlined,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final date = DateTime.tryParse(value);
                      if (date == null) return 'Enter a valid date';
                      if (date.isAfter(DateTime.now())) {
                        return 'Date cannot be in the future';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: context.spacingMd),
                Text('Gender', style: context.label),
                SizedBox(height: context.spacingSm),
                Wrap(
                  spacing: context.spacingSm,
                  runSpacing: context.spacingSm,
                  children: _genders
                      .map(
                        (gender) => ChoiceChip(
                          label: Text(gender),
                          selected: _selectedGender == gender,
                          onSelected: (selected) {
                            setState(
                              () => _selectedGender = selected ? gender : null,
                            );
                          },
                          selectedColor: context.accent.withValues(alpha: 0.2),
                          checkmarkColor: context.accent,
                          backgroundColor: context.surfaceAlt,
                          labelStyle: context.bodySmall,
                        ),
                      )
                      .toList(),
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
    );
  }
}
