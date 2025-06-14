
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
}