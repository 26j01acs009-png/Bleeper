import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/features/profile/domain/models/profile_model.dart';
import 'package:bleeper/core/errors/app_error.dart';
import 'package:path/path.dart' as p;

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(data);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Record not found
      }
      throw AppError('Failed to fetch profile: $e');
    }
  }

  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final extension = p.extension(filePath);
      final fileName = '$userId$extension';

      await _supabase.storage
          .from('avatars')
          .uploadBinary(fileName, bytes);

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw AppError('Failed to upload avatar: $e');
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
    } catch (e) {
      throw AppError('Failed to update profile: $e');
    }
  }
}
