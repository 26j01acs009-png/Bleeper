import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/app_error.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Map<String, dynamic>> createProfile({
    required String userId,
    required String email,
  }) async {
    try {
      final response = await _client.from('profiles').upsert({
        'id': userId,
        'email': email,
      });
      return response;
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    String? website,
    String? location,
  }) async {
    try {
      await _client.from('profiles').upsert({
        'id': userId,
        'display_name': displayName,
        'bio': bio,
        'avatar_url': avatarUrl,
        'banner_url': bannerUrl,
        'website': website,
        'location': location,
      });
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }
}

final profileRepository = ProfileRepository(Supabase.instance.client);