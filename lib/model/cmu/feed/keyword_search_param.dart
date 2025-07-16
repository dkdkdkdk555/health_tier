class KeywordSearchParam {
  final String keyword;
  final int? cursorId;
  final int limit;

  KeywordSearchParam({
    required this.keyword,
    this.cursorId,
    this.limit = 10,
  });

  KeywordSearchParam copyWith({
    int? userId,
    int? cursorId,
    int? limit,
  }) {
    return KeywordSearchParam(
      keyword: keyword,
      cursorId: cursorId ?? this.cursorId,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() => {
    'keyword': keyword,
    'cursorId': cursorId,
    'limit': limit,
  };
}
