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
    } catch (e) {
      _discussions = [];
    } finally {
      _isLoadingDiscussions = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<bool> toggleAppreciate(String userId, String bleepId) async {
    try {
      final isActive = await _repository.toggleAppreciate(userId, bleepId);
      _isAppreciatedByMe = isActive;

      if (_bleepDetail != null) {
        _bleepDetail = _bleepDetail!.copyWith(
          isAppreciatedByMe: isActive,
        );
      }

      if (!_isDisposed) notifyListeners();
      return isActive;
    } catch (e) {
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleReshare(String userId, String bleepId) async {
    try {
      final isActive = await _repository.toggleReshare(userId, bleepId);
      _isResharedByMe = isActive;

      if (_bleepDetail != null) {
        _bleepDetail = _bleepDetail!.copyWith(
          isResharedByMe: isActive,
        );
      }

      if (!_isDisposed) notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
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
      await _repository.addDiscussion(
        bleepId: _currentBleepId!,
        userId: userId,
        content: content,
      );

      if (_bleepDetail != null) {
        _bleepDetail = _bleepDetail!.copyWith(
          discussesCount: _bleepDetail!.discussesCount + 1,
        );
      }

      await _loadDiscussions(_currentBleepId!);
    } catch (e) {
      _error = e.toString();
      if (!_isDisposed) notifyListeners();
    }
  }
}
