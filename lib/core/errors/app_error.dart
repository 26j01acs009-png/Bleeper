class AppError {
  final String message;
  final String? code;

  AppError(this.message, {this.code});

  factory AppError.fromAuthException(Object e) {
    final string = e.toString().toLowerCase();
    if (string.contains('invalid login credentials')) {
      return AppError('Invalid email or password', code: 'invalid_credentials');
    }
    if (string.contains('user already exists') || string.contains('email already registered')) {
      return AppError('User with this email already exists', code: 'user_exists');
    }
    if (string.contains('signup requires a valid password')) {
      return AppError('Password must be at least 6 characters', code: 'weak_password');
    }
    if (string.contains('invalid email')) {
      return AppError('Please enter a valid email address', code: 'invalid_email');
    }
    if (string.contains('rate limit') || string.contains('too many requests')) {
      return AppError('Too many requests. Please wait and try again.', code: 'rate_limit');
    }
    if (string.contains('email not found')) {
      return AppError('Email not found.', code: 'email_not_found');
    }
    if (string.contains('token has expired') || string.contains('expired')) {
      return AppError('Code expired. Please request a new code.', code: 'code_expired');
    }
    if (string.contains('already been used') || string.contains('already used')) {
      return AppError('Code already used. Please request a new code.', code: 'code_used');
    }
    if (string.contains('invalid token') || string.contains('invalid otp') || string.contains('wrong code')) {
      return AppError('Invalid code. Please check and try again.', code: 'invalid_code');
    }
    if (string.contains('network') || string.contains('socket') || string.contains('connection')) {
      return AppError('Network failure. Please check your connection.', code: 'network_error');
    }
    final raw = e.toString();
    return AppError('An unexpected error occurred: $raw');
  }

  @override
  String toString() => message;
}