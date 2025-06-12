
class FeedQueryParams {
  final String? category;
  final String? hotYn;
  final int? cursorId;
  final int limit;

  FeedQueryParams({
    this.category,
    this.hotYn,
    this.cursorId,
    this.limit = 10,
  });
}