class FeedDetailDto {
  final int id;
  final int categoryId;
  final String categoryName;
  final String title;
  final String ctnt;
  final int userId;
  final String nickname;
  final String imgPath;
  final int likeCnt;
  final bool? isLiked;
  final bool? isReportedForMe;
  final int views;
  final String displayDttm;
  final int replyCount;
  final int? crtifiNums;
  final String? crtifiWho;
  final int? crtifiId;

  FeedDetailDto({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.ctnt,
    required this.userId,
    required this.nickname,
    required this.imgPath,
    required this.likeCnt,
    required this.isLiked,
    required this.isReportedForMe,
    required this.views,
    required this.displayDttm,
    required this.replyCount,
    this.crtifiNums,
    this.crtifiWho,
    this.crtifiId,
  });

  factory FeedDetailDto.fromJson(Map<String, dynamic> json) {
    return FeedDetailDto(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      ctnt: json['ctnt'] as String? ?? '',
      userId: json['userId'] as int,
      nickname: json['nickname'] as String? ?? '',
      imgPath: json['imgPath'] as String? ?? '',
      likeCnt: json['likeCnt'] as int,
      isLiked: json['isLiked'] as bool? ?? false,
      isReportedForMe: json['isReportedForMe'] as bool? ?? false,
      views: json['views'] as int,
      displayDttm: json['displayDttm'] as String? ?? '',
      replyCount: json['replyCount'] as int,
    );
  }
}
