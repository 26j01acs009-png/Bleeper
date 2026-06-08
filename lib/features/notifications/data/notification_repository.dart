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
          .select()
          .eq('recipient_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      final notifications = data.map((json) => NotificationModel.fromJson(json)).toList();

      final actorIds = notifications.map((n) => n.actorId).toSet().toList();
      if (actorIds.isEmpty) return notifications;

      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, username, display_name, avatar_url')
          .inFilter('id', actorIds);

      final profilesList = profilesResponse as List<dynamic>;
      final profilesMap = {for (final p in profilesList) p['id'] as String: p};

      return notifications.map((n) {
        final profile = profilesMap[n.actorId];
        return NotificationModel(
          id: n.id,
          recipientId: n.recipientId,
          actorId: n.actorId,
          actorUsername: profile?['username'] ?? n.actorUsername,
          actorDisplayName: profile?['display_name'] ?? n.actorDisplayName,
          actorAvatarUrl: profile?['avatar_url'] ?? n.actorAvatarUrl,
          type: n.type,
          bleepId: n.bleepId,
          bleepContent: n.bleepContent,
          bleepMediaUrl: n.bleepMediaUrl,
          isRead: n.isRead,
          createdAt: n.createdAt,
        );
      }).toList();
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
