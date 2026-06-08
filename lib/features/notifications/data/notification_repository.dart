import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';
import 'package:bleeper/features/notifications/data/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*, profiles:actor_id(username, display_name, avatar_url), bleeps:bleep_id(content, media_url)')
          .eq('recipient_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw AppError('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw AppError('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw AppError('Failed to mark all notifications as read: $e');
    }
  }
}
