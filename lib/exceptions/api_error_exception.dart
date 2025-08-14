
import 'package:my_app/model/usr/auth/error_response.dart';

class ApiErrorException implements Exception {
  final ErrorResponse errorResponse;

  ApiErrorException({required this.errorResponse});

  @override
  String toString() {
    return 'ApiErrorException: Code=${errorResponse.code}, Message=${errorResponse.message}, Status=${errorResponse.status}';
  }
}