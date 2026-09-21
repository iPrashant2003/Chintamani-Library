sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}
class NetworkException extends AppException { const NetworkException(String message) : super(message); }
class AuthException extends AppException { const AuthException(String message) : super(message); }
class ServerException extends AppException { const ServerException(String message) : super(message); }
class NotFoundException extends AppException { const NotFoundException(String message) : super(message); }
class ValidationException extends AppException { const ValidationException(String message) : super(message); }
