import 'package:flutter/foundation.dart';
import 'package:bleeper/features/profile/data/profile_repository.dart';
import 'package:bleeper/features/profile/domain/models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProfile(profile);
      _profile = profile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadAvatar(String userId, String filePath) async {
    return await _repository.uploadAvatar(userId, filePath);
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
