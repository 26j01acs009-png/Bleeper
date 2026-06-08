import 'package:flutter/foundation.dart';
import 'package:bleeper/features/explore/data/explore_repository.dart';
import 'package:bleeper/features/home/domain/entities/bleep.dart';
import 'package:bleeper/features/home/data/bleep_repository.dart';

class ExploreProvider extends ChangeNotifier {
  final ExploreRepository _repository;
  final BleepRepository _bleepRepository;

  ExploreProvider(this._repository, this._bleepRepository);

  List<Map<String, dynamic>> _trendingKeywords = [];
  List<Map<String, dynamic>> get trendingKeywords => _trendingKeywords;

  List<Bleep> _trendingBleeps = [];
  List<Bleep> get trendingBleeps => _trendingBleeps;

  List<Map<String, dynamic>> _suggestedCircles = [];
  List<Map<String, dynamic>> get suggestedCircles => _suggestedCircles;

  List<Map<String, dynamic>> _suggestedUsers = [];
  List<Map<String, dynamic>> get suggestedUsers => _suggestedUsers;

  final Set<String> _followedUserIds = {};
  bool isFollowing(String userId) => _followedUserIds.contains(userId);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  Future<void> loadExploreData(String userId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getTrendingKeywords(),
        _repository.getTrendingBleeps(),
        _repository.getSuggestedCircles(userId),
        _repository.getSuggestedUsers(userId),
      ]);

      _trendingKeywords = results[0];
      _trendingBleeps = (results[1] as List)
          .map((e) => Bleep.fromJson(e))
          .toList();
      _suggestedCircles = results[2];
      _suggestedUsers = results[3];
      _hasLoadedOnce = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userId) async {
    await loadExploreData(userId);
  }

  Future<void> toggleFollow(String followerId, String followingId) async {
    final success = await _bleepRepository.toggleFollow(followerId, followingId);
    if (success) {
      if (_followedUserIds.contains(followingId)) {
        _followedUserIds.remove(followingId);
      } else {
        _followedUserIds.add(followingId);
      }
      notifyListeners();
    }
  }
}
