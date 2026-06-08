import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';
import 'package:bleeper/features/home/domain/entities/bleep.dart';

class ExploreRepository {
  final SupabaseClient _supabase;

  ExploreRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getTrendingKeywords({
    int limit = 20,
    int hoursBack = 24,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_trending_keywords',
        params: {
          'p_limit': limit,
          'p_hours_back': hoursBack,
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AppError('Failed to fetch trending keywords: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingBleeps({
    int limit = 20,
    int hoursBack = 48,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_trending_bleeps',
        params: {
          'p_limit': limit,
          'p_hours_back': hoursBack,
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AppError('Failed to fetch trending bleeps: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSuggestedCircles(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_suggested_circles',
        params: {
          'p_user_id': userId,
          'p_limit': 15,
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AppError('Failed to fetch suggested circles: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSuggestedUsers(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_suggested_users',
        params: {
          'p_user_id': userId,
          'p_limit': 20,
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AppError('Failed to fetch suggested users: $e');
    }
  }

  Future<List<Bleep>> searchBleeps(String query, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('bleeps')
          .select('*, profiles(username, display_name, avatar_url), bleep_stats(*)')
          .ilike('content', '%$query%')
          .eq('visibility', 'public')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => Bleep.fromJson(json)).toList();
    } catch (e) {
      throw AppError('Failed to search bleeps: $e');
    }
  }
}
