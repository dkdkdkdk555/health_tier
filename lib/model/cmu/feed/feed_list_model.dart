class FeedPreviewDto {
  final int id;
  final String category;
  final int categoryId;
  final String title;
  final String ctntPreview;
  final int replyCnt;
  final int likeCnt;
  final int views;
  final DateTime createDttm;

  FeedPreviewDto({
    required this.id,
    required this.category,
    required this.categoryId,
    required this.title,
    required this.ctntPreview,
    required this.replyCnt,
    required this.likeCnt,
    required this.views,
    required this.createDttm,
  });

  factory FeedPreviewDto.fromJson(Map<String, dynamic> json) {
    return FeedPreviewDto(
      id: json['id'] as int,
      category: json['category'] as String,
      categoryId: json['category_id'] as int,
      title: json['title'] as String,
      ctntPreview: json['ctntPreview'] as String,
      replyCnt: json['replyCnt'] ?? 0,
      likeCnt: json['likeCnt'] ?? 0,
      views: json['views'] ?? 0,
      createDttm: DateTime.parse(json['createDttm']),
    );
  }
}
