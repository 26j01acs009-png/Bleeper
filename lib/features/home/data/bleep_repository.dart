import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';
import 'package:bleeper/features/home/domain/entities/bleep.dart';

class BleepRepository {
  final SupabaseClient _supabase;

  BleepRepository(this._supabase);

  Future<List<Bleep>> getHomefeed(
    String userId,
    String feedType, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final rpcName = switch (feedType) {
        'circles' => 'get_circles_feed',
        'following' => 'get_following_feed',
        _ => 'get_for_you_feed',
      };
      final response = await _supabase.rpc(
        rpcName,
        params: {
          'p_user_id': userId,
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      final data = response as List<dynamic>;
      return data.map((json) => Bleep.fromJson(json)).toList();
    } catch (e) {
      throw AppError('Failed to fetch homefeed: $e');
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
      throw AppError('Failed to toggle appreciate: $e');
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
      throw AppError('Failed to toggle reshare: $e');
    }
  }

  Future<void> createBleep({
    required String userId,
    required String content,
    String? mediaUrl,
    String? circleId,
    String visibility = 'public',
    String replyPermission = 'everyone',
    String resharePermission = 'everyone',
  }) async {
    try {
      await _supabase.from('bleeps').insert({
        'user_id': userId,
        'content': content,
        'media_url': mediaUrl,
        'circle_id': circleId,
        'visibility': visibility,
        'reply_permission': replyPermission,
        'reshare_permission': resharePermission,
      });
    } catch (e) {
      throw AppError('Failed to create bleep: $e');
    }
  }

  Future<bool> toggleFollow(String followerId, String followingId) async {
    try {
      final existing = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', followerId)
            .eq('following_id', followingId);
        return false;
      } else {
        await _supabase.from('follows').insert({
          'follower_id': followerId,
          'following_id': followingId,
        });
        return true;
      }
    } catch (e) {
      throw AppError('Failed to toggle follow: $e');
    }
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final existing = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();
      return existing != null;
    } catch (e) {
      return false;
    }
  }
}
