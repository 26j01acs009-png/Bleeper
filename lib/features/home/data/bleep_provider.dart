import 'package:flutter/foundation.dart';
import './bleep_repository.dart';
import 'package:bleeper/features/home/domain/entities/bleep.dart';

class BleepProvider extends ChangeNotifier {
  final BleepRepository _repository;

  BleepProvider(this._repository);

  List<Bleep> _bleeps = [];
  List<Bleep> get bleeps => _bleeps;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchBleeps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bleeps = await _repository.getBleeps();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAppreciate(String userId, String bleepId) async {
    try {
      final isActive = await _repository.toggleAppreciate(userId, bleepId);
      _bleeps = _bleeps.map((model) {
        if (model.id != bleepId) return model;
        return Bleep(
          id: model.id,
          userId: model.userId,
          username: model.username,
          avatarUrl: model.avatarUrl,
          name: model.name,
          content: model.content,
          mediaUrl: model.mediaUrl,
          imageUrl: model.imageUrl,
          appreciatesCount: model.appreciatesCount + (isActive ? 1 : -1),
          discussesCount: model.discussesCount,
          resharesCount: model.resharesCount,
          viewsCount: model.viewsCount,
          isAppreciatedByMe: isActive,
          isResharedByMe: model.isResharedByMe,
          createdAt: model.createdAt,
          visibility: model.visibility,
          replyPermission: model.replyPermission,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleReshare(String userId, String bleepId) async {
    try {
      final isActive = await _repository.toggleReshare(userId, bleepId);
      _bleeps = _bleeps.map((model) {
        if (model.id != bleepId) return model;
        return Bleep(
          id: model.id,
          userId: model.userId,
          username: model.username,
          avatarUrl: model.avatarUrl,
          name: model.name,
          content: model.content,
          imageUrl: model.imageUrl,
          mediaUrl: model.mediaUrl,
          appreciatesCount: model.appreciatesCount,
          discussesCount: model.discussesCount,
          resharesCount: model.resharesCount + (isActive ? 1 : -1),
          viewsCount: model.viewsCount,
          isAppreciatedByMe: model.isAppreciatedByMe,
          isResharedByMe: isActive,
          createdAt: model.createdAt,
          visibility: model.visibility,
          replyPermission: model.replyPermission,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
