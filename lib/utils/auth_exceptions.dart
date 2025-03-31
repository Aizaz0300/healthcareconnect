class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, this.code);

  @override
  String toString() => message;

  static String handleError(dynamic e) {
    if (e.toString().contains('Invalid credentials')) {
      return 'Invalid email or password';
    } else if (e.toString().contains('Email already exists')) {
      return 'An account with this email already exists';
    } else if (e.toString().contains('Rate limit exceeded')) {
      return 'Too many attempts. Please try again later';
    } else if (e.toString().contains('Network is unreachable')) {
      return 'No internet connection. Please check your network';
    }
    return 'An unexpected error occurred. Please try again';
  }
}
