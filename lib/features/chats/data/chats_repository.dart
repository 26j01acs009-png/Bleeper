import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';
import 'package:bleeper/features/profile/domain/models/profile_model.dart';
import 'package:bleeper/features/chats/domain/models/chat_model.dart';

class ChatsRepository {
  final SupabaseClient _supabase;

  ChatsRepository(this._supabase);

  Future<List<Chat>> getChats(String userId) async {
    try {
      final chatsResponse = await _supabase
          .from('chats')
          .select('''
            id,
            last_message_content,
            last_message_at,
            chat_participants!inner(chat_id, user_id)
          ''')
          .eq('chat_participants.user_id', userId)
          .order('last_message_at', ascending: false);

      final chats = chatsResponse as List<dynamic>;
      if (chats.isEmpty) return [];

      final otherUserIds = <String>[];
      final chatIdToOtherUserId = <String, String>{};

      for (final chat in chats) {
        final chatId = chat['id'] as String;
        final participants = chat['chat_participants'] as List<dynamic>;
        for (final p in participants) {
          final uid = p['user_id'] as String;
          if (uid != userId) {
            otherUserIds.add(uid);
            chatIdToOtherUserId[chatId] = uid;
          }
        }
      }

      final uniqueOtherIds = otherUserIds.toSet().toList();
      Map<String, ProfileModel> profileMap = {};
      if (uniqueOtherIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profiles')
            .select()
            .inFilter('id', uniqueOtherIds);
        final profilesList = profilesResponse as List<dynamic>;
        profileMap = {for (final p in profilesList) p['id'] as String: ProfileModel.fromJson(p)};
      }

      final List<Chat> result = [];
      for (final chat in chats) {
        final chatId = chat['id'] as String;
        final otherUserId = chatIdToOtherUserId[chatId];
        final profile = otherUserId != null ? profileMap[otherUserId] : null;

        result.add(Chat(
          id: chatId,
          name: profile?.displayName ?? profile?.username ?? 'Unknown',
          preview: chat['last_message_content'] as String? ?? '',
          timeAgo: _formatTimeAgo(chat['last_message_at'] as String?),
          avatarUrl: profile?.avatarUrl,
          isOnline: profile?.isOnline ?? false,
          unreadCount: null,
          isRead: true,
        ));
      }

      return result;
    } catch (e) {
      throw AppError('Failed to fetch chats: $e');
    }
  }

  String _formatTimeAgo(String? isoString) {
    if (isoString == null) return '';
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Future<bool> chatExists(String user1Id, String user2Id) async {
    try {
      final response = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', user1Id);

      final user1Chats = response as List<dynamic>;
      if (user1Chats.isEmpty) return false;

      final chatIds = user1Chats.map((e) => e['chat_id']).toList();
      final otherParticipants = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .inFilter('chat_id', chatIds)
          .eq('user_id', user2Id);

      return (otherParticipants as List<dynamic>).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getExistingChatId(String user1Id, String user2Id) async {
    try {
      final response = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', user1Id);

      final user1Chats = response as List<dynamic>;
      if (user1Chats.isEmpty) return null;

      final chatIds = user1Chats.map((e) => e['chat_id']).toList();
      final otherParticipants = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .inFilter('chat_id', chatIds)
          .eq('user_id', user2Id);

      final results = otherParticipants as List<dynamic>;
      if (results.isEmpty) return null;
      return results.first['chat_id'] as String;
    } catch (e) {
      return null;
    }
  }

  Future<String> createChat(
      String currentUserId, String otherUserId, String otherUserName) async {
    try {
      final existingId = await getExistingChatId(currentUserId, otherUserId);
      if (existingId != null) return existingId;

      final response = await _supabase.from('chats').insert({
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_message_at': DateTime.now().toIso8601String(),
      }).select();

      final chatId = (response as List<dynamic>).first['id'] as String;

      await _supabase.from('chat_participants').insert([
        {'chat_id': chatId, 'user_id': currentUserId},
        {'chat_id': chatId, 'user_id': otherUserId}
      ]);

      return chatId;
    } catch (e) {
      throw AppError('Failed to create chat: $e');
    }
  }

  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _supabase
          .from('chat_participants')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('chat_id', chatId)
          .eq('user_id', userId);
    } catch (e) {
      throw AppError('Failed to mark chat as read: $e');
    }
  }

  Future<ProfileModel?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return ProfileModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<List<ProfileModel>> searchUsers(String query, String currentUserId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .neq('id', currentUserId)
          .ilike('username', '%$query%')
          .limit(20);

      final data = response as List<dynamic>;
      return data.map((json) => ProfileModel.fromJson(json)).toList();
    } catch (e) {
      throw AppError('Failed to search users: $e');
    }
  }

  Future<List<ProfileModel>> getFollowedUsers(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select('profiles!following_id(id, username, display_name, avatar_url, is_online)')
          .eq('follower_id', userId);

      final data = response as List<dynamic>;
      return data.map((json) {
        final profile = json['profiles'] as Map<String, dynamic>;
        return ProfileModel.fromJson(profile);
      }).toList();
    } catch (e) {
      throw AppError('Failed to fetch followed users: $e');
    }
  }
}
