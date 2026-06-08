import 'package:flutter/foundation.dart';
import 'package:bleeper/features/chats/data/chats_repository.dart';
import 'package:bleeper/features/chats/domain/models/chat_model.dart';

class ChatsProvider with ChangeNotifier {
  final ChatsRepository _repository;

  ChatsProvider(this._repository);

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchChats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chats = await _repository.getChats(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _repository.markAsRead(chatId, userId);
      _chats = _chats.map((c) => c.id == chatId ? c.copyWith(isRead: true) : c).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
