import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../data/profile_provider.dart';
import '../../domain/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.displayName ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    final currentProfile = context.read<ProfileProvider>().profile;
    if (currentProfile == null) return;

    final profileProvider = context.read<ProfileProvider>();
    String? avatarUrl = currentProfile.avatarUrl;

    try {
      if (_pickedImage != null) {
        final userId = currentProfile.id;
        avatarUrl = await profileProvider.uploadAvatar(userId, _pickedImage!.path);
      }

      final updatedProfile = ProfileModel(
        id: currentProfile.id,
        email: currentProfile.email,
        username: _usernameController.text,
        displayName: _nameController.text,
        avatarUrl: avatarUrl,
        bio: _bioController.text,
        updatedAt: DateTime.now(),
      );

      await profileProvider.updateProfile(updatedProfile);
      if (!mounted) return;
      final error = profileProvider.error;
      if (error == null) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: context.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: context.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final isLoading = profileProvider.isLoading;

    if (isLoading && profile == null) {
      return Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: context.textPrimary,
        ),
        body: const Center(child: BleeperLoadingIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.textPrimary,
        actions: [
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (_formKey.currentState?.validate() ?? true) {
                      await _saveProfile();
                    }
                  },
            child: Text(
              'Save',
              style: context.bodyMedium.copyWith(
                color: context.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
          children: [
            SizedBox(height: context.spacingSm),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    backgroundColor: const Color(0xFFE5E7EB),
                    child: _pickedImage == null && profile?.avatarUrl == null
                        ? const DefaultAvatar(size: 96)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.spacingXl),
            BleeperInput(
              controller: _nameController,
              hintText: 'Display name',
              label: 'Display name',
            ),
            SizedBox(height: context.spacingMd),
            BleeperInput(
              controller: _usernameController,
              hintText: 'Username',
              label: 'Username',
              prefixIcon: Icons.alternate_email,
            ),
            SizedBox(height: context.spacingMd),
            BleeperInput(
              controller: _bioController,
              hintText: 'Bio',
              label: 'Bio',
              maxLines: 3,
            ),
            SizedBox(height: context.spacingXxl),
          ],
        ),
      ),
    );
  }
}
