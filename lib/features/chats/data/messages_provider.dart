import 'package:flutter/foundation.dart';
import 'package:bleeper/features/chats/data/messages_repository.dart';
import 'package:bleeper/features/chats/domain/models/chat_message_model.dart';

class MessagesProvider with ChangeNotifier {
  final MessagesRepository _repository;

  MessagesProvider(this._repository);

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    _error = null;
    _messages = [];
    notifyListeners();

    try {
      _messages = await _repository.getMessages(chatId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    _error = null;
    notifyListeners();

    try {
      await _repository.sendMessage(chatId, senderId, text);
      _messages = [
        ..._messages,
        ChatMessage(
          text: text,
          timeAgo: 'now',
          isMe: true,
          isRead: false,
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
