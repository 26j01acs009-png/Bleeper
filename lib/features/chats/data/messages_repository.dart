import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bleeper/core/errors/app_error.dart';
import 'package:bleeper/features/chats/domain/models/chat_message_model.dart';

class MessagesRepository {
  final SupabaseClient _supabase;

  MessagesRepository(this._supabase);

  Future<List<ChatMessage>> getMessages(String chatId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      throw AppError('Failed to fetch messages: $e');
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    try {
      await _supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _supabase.from('chats').update({
        'last_message_content': text,
        'last_message_at': DateTime.now().toIso8601String(),
        'last_message_sender_id': senderId,
      }).eq('id', chatId);
    } catch (e) {
      throw AppError('Failed to send message: $e');
    }
  }
}
