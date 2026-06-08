import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/app_error.dart';
import 'auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier implements Listenable {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _pendingEmail;
  String? get pendingEmail => _pendingEmail;

  AuthProvider._(this._authRepository);

  factory AuthProvider.create() {
    return AuthProvider._(authRepository);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    _user = _authRepository.currentUser;
    _status = _user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    _authRepository.authStateChanges.listen((state) {
      _user = state.session?.user;
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> signUp({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.signUp(email: email, password: password);
      _pendingEmail = email;
    } catch (e) {
      if (e is AppError) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.verifyOtp(
        email: email,
        token: token,
        type: 'emailSignup',
      );

      _pendingEmail = null;
    } catch (e) {
      if (e is AppError) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendVerificationOtp() async {
    if (_pendingEmail == null || _pendingEmail!.isEmpty) return;
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.resendVerificationOtp(_pendingEmail!);
    } catch (e) {
      if (e is AppError) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.login(email: email, password: password);
    } catch (e) {
      if (e is AppError) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
    } catch (e) {
      if (e is AppError) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword({required String email}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.resetPassword(email: email);
    } catch (e) {
      if (e is AppError) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }
}
