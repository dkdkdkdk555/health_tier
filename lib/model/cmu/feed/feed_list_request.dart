class FeedQueryParams {
  int? categoryId;
  String? hotYn;
  int? cursorId;
  final int limit;

  FeedQueryParams({
    this.categoryId,
    this.hotYn,
    this.cursorId,
    this.limit = 10,
  });

  FeedQueryParams copyWith({
    int? categoryId,
    String? hotYn,
    int? cursorId,
    int? limit,
  }) {
    return FeedQueryParams(
      categoryId: categoryId ?? this.categoryId,
      hotYn: hotYn ?? this.hotYn,
      cursorId: cursorId ?? this.cursorId,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'hotYn': hotYn,
        'cursorId': cursorId,
        'limit': limit,
      };
}
