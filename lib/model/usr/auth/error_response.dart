class ErrorResponse {
  final String code;
  final String message;
  final int status;

  ErrorResponse({
    required this.code,
    required this.message,
    required this.status,
  });

  // JSON Map에서 ErrorResponse 객체를 생성하는 팩토리 메서드
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] as String,
      message: json['message'] as String,
      status: json['status'] as int,
    );
  }

  // ErrorResponse 객체를 JSON Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'status': status,
    };
  }
}