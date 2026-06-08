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
          .select('*, profiles(username, display_name, avatar_url)')
          .eq('id', bleepId)
          .single();

      final data = Map<String, dynamic>.from(response);

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
      await _supabase.rpc(
        'increment_bleep_views',
        params: {'bleep_id': bleepId},
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

  Future<void> toggleReshare(String userId, String bleepId) async {
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
      } else {
        await _supabase.from('reshares').insert({
          'user_id': userId,
          'bleep_id': bleepId,
        });
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
        'parent_id': ?parentId,
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
          .isFilter('parent_id', null)
          .order('created_at', ascending: true);

      return response;
    } catch (e) {
      throw AppError('Failed to fetch discussions: $e');
    }
  }
}
