import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bleeper/features/bleep_details/data/bleep_detail_repository.dart';
import 'package:bleeper/features/bleep_details/domain/entities/discussion.dart';
import 'package:bleeper/features/home/domain/entities/bleep.dart';

class BleepDetailProvider extends ChangeNotifier {
  final BleepDetailRepository _repository;

  BleepDetailProvider(this._repository);

  Bleep? _bleepDetail;
  Bleep? get bleepDetail => _bleepDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingDiscussions = false;
  bool get isLoadingDiscussions => _isLoadingDiscussions;

  String? _discussionsError;
  String? get discussionsError => _discussionsError;

  String? _error;
  String? get error => _error;

  bool _isAppreciatedByMe = false;
  bool get isAppreciatedByMe => _isAppreciatedByMe;

  bool _isResharedByMe = false;
  bool get isResharedByMe => _isResharedByMe;

  List<Discussion> _discussions = [];
  List<Discussion> get discussions => _discussions;

  String? _currentBleepId;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadBleepDetail(String bleepId) async {
    _isLoading = true;
    _error = null;
    _bleepDetail = null;
    _isAppreciatedByMe = false;
    _isResharedByMe = false;
    _discussions = [];
    _currentBleepId = bleepId;
    notifyListeners();

    try {
      final json = await _repository.getBleepDetail(bleepId);
      _bleepDetail = Bleep.fromJson(json);
      _isAppreciatedByMe = _bleepDetail!.isAppreciatedByMe;
      _isResharedByMe = _bleepDetail!.isResharedByMe;
      await _loadDiscussions(bleepId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> _loadDiscussions(String bleepId) async {
    _isLoadingDiscussions = true;
    notifyListeners();

    try {
      final jsonList = await _repository.getDiscussions(bleepId);
      _discussions = jsonList.map((json) => Discussion.fromJson(json)).toList();
      _discussionsError = null;
    } catch (e) {
      _discussions = [];
      _discussionsError = e.toString();
    } finally {
      _isLoadingDiscussions = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<bool> toggleAppreciate(String userId, String bleepId) async {
    final old = _bleepDetail;
    if (old == null) return false;
    final nowActive = !_isAppreciatedByMe;

    _bleepDetail = old.copyWith(
      isAppreciatedByMe: nowActive,
      appreciatesCount: old.appreciatesCount + (nowActive ? 1 : -1),
    );
    _isAppreciatedByMe = nowActive;
    if (!_isDisposed) notifyListeners();

    try {
      final isActive = await _repository.toggleAppreciate(userId, bleepId);
      if (isActive != nowActive) {
        _bleepDetail = old.copyWith(
          isAppreciatedByMe: isActive,
          appreciatesCount: old.appreciatesCount + (isActive ? 1 : -1),
        );
        _isAppreciatedByMe = isActive;
        if (!_isDisposed) notifyListeners();
      }
      return isActive;
    } catch (e) {
      _bleepDetail = old;
      _isAppreciatedByMe = !nowActive;
      if (!_isDisposed) notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleReshare(String userId, String bleepId) async {
    final old = _bleepDetail;
    if (old == null) return;
    final nowActive = !_isResharedByMe;

    _bleepDetail = old.copyWith(
      isResharedByMe: nowActive,
      resharesCount: old.resharesCount + (nowActive ? 1 : -1),
    );
    _isResharedByMe = nowActive;
    if (!_isDisposed) notifyListeners();

    try {
      final isActive = await _repository.toggleReshare(userId, bleepId);
      if (isActive != nowActive) {
        _bleepDetail = old.copyWith(
          isResharedByMe: isActive,
          resharesCount: old.resharesCount + (isActive ? 1 : -1),
        );
        _isResharedByMe = isActive;
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      _bleepDetail = old;
      _isResharedByMe = !nowActive;
      if (!_isDisposed) notifyListeners();
      rethrow;
    }
  }

  Future<void> addDiscussion({
    required String userId,
    required String content,
  }) async {
    if (_currentBleepId == null) {
      _error = 'No bleep selected';
      if (!_isDisposed) notifyListeners();
      return;
    }

    try {
      final discussionId = await _repository.addDiscussion(
        bleepId: _currentBleepId!,
        userId: userId,
        content: content,
      );

      final profile = await _repository.getUserProfile(userId);

      final newDiscussion = Discussion(
        id: discussionId,
        bleepId: _currentBleepId!,
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
        username: profile?['username'] as String?,
        displayName: profile?['display_name'] as String?,
        avatarUrl: profile?['avatar_url'] as String?,
      );

      _discussions = List<Discussion>.from(_discussions)..add(newDiscussion);
      _bleepDetail = _bleepDetail?.copyWith(
        discussesCount: (_bleepDetail?.discussesCount ?? 0) + 1,
      );
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> deleteDiscussion(String discussionId) async {
    if (_currentBleepId == null) return;

    final index = _discussions.indexWhere((d) => d.id == discussionId);
    if (index == -1) return;

    final oldDetail = _bleepDetail;
    final oldDiscussions = List<Discussion>.from(_discussions);

    _discussions.removeAt(index);
    _bleepDetail = _bleepDetail?.copyWith(
      discussesCount: (_bleepDetail?.discussesCount ?? 1) - 1,
    );
    if (!_isDisposed) notifyListeners();

    try {
      await _repository.deleteDiscussion(discussionId);
    } catch (e) {
      _discussions = oldDiscussions;
      _bleepDetail = oldDetail;
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
    }
  }
}
