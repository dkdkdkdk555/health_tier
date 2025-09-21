import 'package:my_app/model/cmu/feed/badge_info_dto.dart' show BadgeInfoDto;

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
  final List<BadgeInfoDto>? badges;

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
    this.badges,
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
      // badges 리스트가 null일 경우를 대비해 `as List<dynamic>?` 추가 및 `e`를 `Map<String, dynamic>`으로 명시적 캐스팅
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => BadgeInfoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
