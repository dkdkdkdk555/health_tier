class UsrsFeedQueryParams {
  int? userId;
  int? cursorId;
  final int limit;

  UsrsFeedQueryParams({
    this.userId,
    this.cursorId,
    this.limit = 10,
  });

  UsrsFeedQueryParams copyWith({
    int? userId,
    int? cursorId,
    int? limit,
  }) {
    return UsrsFeedQueryParams(
      userId: userId ?? this.userId,
      cursorId: cursorId ?? this.cursorId,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'cursorId': cursorId,
        'limit': limit,
      };
}
