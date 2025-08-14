class ReLoginRequiredException implements Exception {
  final String message;

  ReLoginRequiredException([this.message = "다시 로그인해야 합니다."]);

  @override
  String toString() => 'ReLoginRequiredException: $message';
}