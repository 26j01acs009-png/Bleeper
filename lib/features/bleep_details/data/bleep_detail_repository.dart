import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';

class BleepDetailRepository {
  final SupabaseClient _supabase;

  BleepDetailRepository(this._supabase);

  Future<Map<String, dynamic>> getBleepDetail(String bleepId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final bleepResponse = await _supabase
          .from('bleeps')
          .select()
          .eq('id', bleepId)
          .single();

      final data = Map<String, dynamic>.from(bleepResponse);

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

      final statsResponse = await _supabase
          .from('bleep_stats')
          .select('*')
          .eq('bleep_id', bleepId)
          .maybeSingle();

      if (statsResponse != null) {
        data['bleep_stats'] = statsResponse;
      }

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

  Future<String> addDiscussion({
    required String bleepId,
    required String userId,
    required String content,
    String? parentId,
  }) async {
    try {
      final response = await _supabase.from('discussions').insert({
        'bleep_id': bleepId,
        'user_id': userId,
        'content': content,
        'parent_id': parentId,
      }).select('id').single();
      return response['id'] as String;
    } catch (e) {
      throw AppError('Failed to add discussion: $e');
    }
  }

  Future<void> deleteDiscussion(String discussionId) async {
    try {
      await _supabase
          .from('discussions')
          .delete()
          .eq('id', discussionId);
    } catch (e) {
      throw AppError('Failed to delete discussion: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('username, display_name, avatar_url')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDiscussions(String bleepId) async {
    try {
      final discussions = await _supabase
          .from('discussions')
          .select()
          .eq('bleep_id', bleepId)
          .order('created_at', ascending: true);

      final userIds = discussions
          .map((d) => d['user_id'] as String)
          .toSet()
          .toList();

      final profiles = <String, Map<String, dynamic>>{};
      if (userIds.isNotEmpty) {
        final profileRows = await _supabase
            .from('profiles')
            .select('id, username, display_name, avatar_url')
            .inFilter('id', userIds);

        for (final row in profileRows) {
          profiles[row['id'] as String] = row;
        }
      }

      return discussions.map((d) {
        final uid = d['user_id'] as String;
        final profile = profiles[uid];
        return Map<String, dynamic>.from(d)
          ..addAll({
            'profiles': profile,
          });
      }).toList();
    } catch (e) {
      throw AppError('Failed to fetch discussions: $e');
    }
  }
}
