import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';
import 'package:bleeper/features/home/domain/entities/bleep.dart';

class BleepRepository {
  final SupabaseClient _supabase;

  BleepRepository(this._supabase);

  Future<List<Bleep>> getBleeps() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('bleeps')
          .select('*, profiles(username, avatar_url, display_name)')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      var bleeps = data.map((json) => Bleep.fromJson(json)).toList();

      if (userId != null) {
        final appreciations = await _supabase
            .from('appreciations')
            .select('bleep_id')
            .eq('user_id', userId);

        final appreciatedIds = appreciations.map((a) => a['bleep_id'] as String).toSet();

        final reshares = await _supabase
            .from('reshares')
            .select('bleep_id')
            .eq('user_id', userId);

        final resharedIds = reshares.map((r) => r['bleep_id'] as String).toSet();

        bleeps = bleeps.map((bleep) {
          return bleep.copyWith(
            isAppreciatedByMe: appreciatedIds.contains(bleep.id),
            isResharedByMe: resharedIds.contains(bleep.id),
          );
        }).toList();
      }

      return bleeps;
    } catch (e) {
      throw AppError('Failed to fetch bleeps: $e');
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
        await _supabase
            .from('appreciations')
            .insert({'user_id': userId, 'bleep_id': bleepId});
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
        await _supabase
            .from('reshares')
            .insert({'user_id': userId, 'bleep_id': bleepId});
        return true;
      }
    } catch (e) {
      throw AppError('Failed to toggle reshare: $e');
    }
  }

  Future<void> createBleep({
    required String authorId,
    required String content,
    String? mediaUrl,
    String visibility = 'public',
    String replyPermission = 'everyone',
  }) async {
    try {
      await _supabase
          .from('bleeps')
          .insert({
            'author_id': authorId,
            'content': content,
            'media_url': mediaUrl,
            'visibility': visibility,
            'reply_permission': replyPermission,
            'reshare_permission': 'everyone',
          });
    } catch (e) {
      throw AppError('Failed to create bleep: $e');
    }
  }
}
