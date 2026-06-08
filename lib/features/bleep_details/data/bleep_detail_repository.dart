import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';

class BleepDetailRepository {
  final SupabaseClient _supabase;

  BleepDetailRepository(this._supabase);

  Future<Map<String, dynamic>> getBleepDetail(String bleepId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('bleeps')
          .select()
          .eq('id', bleepId)
          .single();

      final data = Map<String, dynamic>.from(response);

      if (data['user_id'] != null) {
        final profileResponse = await _supabase
            .from('profiles')
            .select('username, display_name, avatar_url')
            .eq('id', data['user_id'] as String)
            .maybeSingle();

        if (profileResponse != null) {
          data['profiles'] = profileResponse;
        }
      }

      final stats = data['bleep_stats'] as Map<String, dynamic>?;

      data['appreciates_count'] = stats?['appreciates_count'] as int? ?? 0;
      data['discusses_count'] = stats?['discusses_count'] as int? ?? 0;
      data['reshares_count'] = stats?['reshares_count'] as int? ?? 0;
      data['views_count'] = stats?['views_count'] as int? ?? data['view_count'] as int? ?? 0;

      if (userId != null) {
        final appreciation = await _supabase
            .from('appreciations')
            .select()
            .eq('user_id', userId)
            .eq('bleep_id', bleepId)
            .maybeSingle();

        data['is_appreciated_by_me'] = appreciation != null;

        final reshare = await _supabase
            .from('reshares')
            .select()
            .eq('user_id', userId)
            .eq('bleep_id', bleepId)
            .maybeSingle();

        data['is_reshared_by_me'] = reshare != null;
      } else {
        data['is_appreciated_by_me'] = false;
        data['is_reshared_by_me'] = false;
      }

      return data;
    } catch (e) {
      throw AppError('Failed to fetch bleep detail: $e');
    }
  }

  Future<void> incrementViews(String bleepId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      await _supabase.rpc(
        'increment_bleep_views',
        params: {'p_bleep_id': bleepId, 'p_user_id': userId},
      );
    } catch (e) {
      // Non-critical, fail silently
    }
  }

  Future<bool> toggleAppreciate(String userId, String bleepId) async {
    try {
      final existing = await _supabase
          .from('appreciations')
          .select()
          .eq('user_id', userId)
          .eq('bleep_id', bleepId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('appreciations')
            .delete()
            .eq('user_id', userId)
            .eq('bleep_id', bleepId);
        return false;
      } else {
        await _supabase.from('appreciations').insert({
          'user_id': userId,
          'bleep_id': bleepId,
        });
        return true;
      }
    } catch (e) {
      throw AppError('Failed to update appreciation: $e');
    }
  }

  Future<bool> toggleReshare(String userId, String bleepId) async {
    try {
      final existing = await _supabase
          .from('reshares')
          .select()
          .eq('user_id', userId)
          .eq('bleep_id', bleepId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('reshares')
            .delete()
            .eq('user_id', userId)
            .eq('bleep_id', bleepId);
        return false;
      } else {
        await _supabase.from('reshares').insert({
          'user_id': userId,
          'bleep_id': bleepId,
        });
        return true;
      }
    } catch (e) {
      throw AppError('Failed to update reshare: $e');
    }
  }

  Future<void> addDiscussion({
    required String bleepId,
    required String userId,
    required String content,
    String? parentId,
  }) async {
    try {
      await _supabase.from('discussions').insert({
        'bleep_id': bleepId,
        'user_id': userId,
        'content': content,
        'parent_id': parentId,
      });
    } catch (e) {
      throw AppError('Failed to add discussion: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDiscussions(String bleepId) async {
    try {
      final response = await _supabase
          .from('discussions')
          .select('*, profiles(username, display_name, avatar_url)')
          .eq('bleep_id', bleepId)
          .filter('parent_id', 'is', null)
          .order('created_at', ascending: true);

      return response;
    } catch (e) {
      throw AppError('Failed to fetch discussions: $e');
    }
  }
}
