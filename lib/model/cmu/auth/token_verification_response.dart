class TokenVerificationResponse {
  final bool isValid;
  final int? userId; // 유효할 경우에만 존재할 수 있으므로 nullable
  final String? error; // 유효하지 않을 경우에만 존재할 수 있으므로 nullable
  final String? message; // 유효할 경우에만 존재할 수 있으므로 nullable

  TokenVerificationResponse({
    required this.isValid,
    this.userId,
    this.error,
    this.message,
  });

  factory TokenVerificationResponse.fromJson(Map<String, dynamic> json) {
    return TokenVerificationResponse(
      isValid: json['isValid'] as bool,
      userId: json['userId'] is int ? json['userId'] as int : null,
      error: json['error'] is String ? json['error'] as String : null,
      message: json['message'] is String ? json['message'] as String : null,
    );
  }

  @override
  String toString() {
    return 'TokenVerificationResponse(isValid: $isValid, userId: $userId, error: $error, message: $message)';
  }
}