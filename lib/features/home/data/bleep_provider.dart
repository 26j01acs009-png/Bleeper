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

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  int _offset = 0;
  static const _pageSize = 20;

  final Map<String, DateTime> _lastSeenAt = {};

  final Set<String> _tabsWithNewPosts = {};
  bool hasNewPosts(String feedType) => _tabsWithNewPosts.contains(feedType);

  Future<void> fetchBleeps(
    String? userId,
    String feedType, {
    bool reset = true,
  }) async {
    if (reset) {
      _offset = 0;
      _hasMore = true;
      _bleeps = [];
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBleeps = await _repository.getHomefeed(
        userId ?? '',
        feedType,
        limit: _pageSize,
        offset: _offset,
      );

      if (reset) {
        _bleeps = newBleeps;
        if (newBleeps.isNotEmpty) {
          _lastSeenAt[feedType] = newBleeps.first.createdAt;
        }
      } else {
        _bleeps = [..._bleeps, ...newBleeps];
      }

      _offset += newBleeps.length;
      _hasMore = newBleeps.length >= _pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markTabSeen(String feedType) {
    _tabsWithNewPosts.remove(feedType);
    notifyListeners();
  }

  void markTabAsNew(String feedType) {
    _tabsWithNewPosts.add(feedType);
    notifyListeners();
  }

  Future<void> checkForNewPosts(String userId, String feedType) async {
    try {
      final latest = await _repository.getHomefeed(
        userId,
        feedType,
        limit: 1,
        offset: 0,
      );
      if (latest.isNotEmpty) {
        final newestAt = latest.first.createdAt;
        final lastSeen = _lastSeenAt[feedType];
        if (lastSeen != null && newestAt.isAfter(lastSeen)) {
          markTabAsNew(feedType);
        }
      }
    } catch (_) {
      // fail silently for background checks
    }
  }

  Future<void> refreshBleeps(String? userId, String feedType) async {
    await fetchBleeps(userId, feedType, reset: true);
  }

  Future<void> loadMore(String? userId, String feedType) async {
    if (_isLoading || !_hasMore) return;
    await fetchBleeps(userId, feedType, reset: false);
  }

  Future<void> toggleAppreciate(String userId, String bleepId) async {
    await _repository.toggleAppreciate(userId, bleepId);
    notifyListeners();
  }

  Future<void> toggleReshare(String userId, String bleepId) async {
    await _repository.toggleReshare(userId, bleepId);
    notifyListeners();
  }
}
