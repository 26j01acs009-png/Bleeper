import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/app_error.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String token,
    required String type,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Future<void> resendVerificationOtp(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw AppError.fromAuthException(e);
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;
}

final authRepository = AuthRepository(Supabase.instance.client);