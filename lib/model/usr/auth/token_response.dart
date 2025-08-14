class TokenResponse {
  final String accessToken;
  final String? refreshToken;
  final int userId;

  TokenResponse({
    required this.accessToken,
    this.refreshToken,
    required this.userId,
  });

  // JSON Map에서 TokenResponse 객체를 생성하는 팩토리 메서드
  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as int,
    );
  }

  // TokenResponse 객체를 JSON Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
    };
  }
}