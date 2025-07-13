class FeedPreviewDto {
  final int id;
  final String category;
  final int categoryId;
  final String title;
  final String? ctntPreview;
  final String? imgPreview;
  final int replyCnt;
  final int likeCnt;
  final int views;
  final String viewDttm;
  final String nickName;
  final String? userImgPath;
  final String? tier;

  FeedPreviewDto({
    required this.id,
    required this.category,
    required this.categoryId,
    required this.title,
    required this.ctntPreview,
    required this.imgPreview,
    required this.replyCnt,
    required this.likeCnt,
    required this.views,
    required this.viewDttm,
    required this.nickName,
    required this.userImgPath,
    required this.tier
  });

  factory FeedPreviewDto.fromJson(Map<String, dynamic> json) {
    return FeedPreviewDto(
      id: json['id'] as int,
      category: json['category'] ?? '',
      categoryId: json['categoryId'] as int,
      title: json['title'] ?? '',
      ctntPreview: json['ctntPreview'] as String?,
      imgPreview: json['imgPreview'] as String?,
      replyCnt: json['replyCnt'] ?? 0,
      likeCnt: json['likeCnt'] ?? 0,
      views: json['views'] ?? 0,
      viewDttm: json['viewDttm'] ?? '',
      nickName: json['nickName'] ?? '',
      userImgPath: json['userImgPath'] as String?,
      tier: json['tier'] as String?,
    );
  }
}
