import 'package:my_app/model/cmu/feed/certifi_user_dto.dart';
import 'package:my_app/model/cmu/feed/user_weight_crtifi_dto.dart';

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
  String? crtifiYn;
  String? crtifiWho;
  int? crtifiId;
  List<UserWeightCrtifiDto>? weightCertifications;
  List<CertifiUserDto>? certifiedUsers;

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
    this.crtifiYn,
    this.crtifiWho,
    this.crtifiId,
    this.weightCertifications,
    this.certifiedUsers,
  });

  factory FeedDetailDto.fromJson(Map<String, dynamic> json) {
    return FeedDetailDto(
      id: json['id'] as int? ?? 0,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      ctnt: json['ctnt'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
      nickname: json['nickname'] as String? ?? '',
      imgPath: json['imgPath'] as String? ?? '',
      likeCnt: json['likeCnt'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isReportedForMe: json['isReportedForMe'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      displayDttm: json['displayDttm'] as String? ?? '',
      replyCount: json['replyCount'] as int? ?? 0,
      crtifiYn: json['crtifiYn'] as String? ?? '',
      crtifiWho: json['crtifiWho'] as String? ?? '',
      crtifiId: json['crtifiId'] as int? ?? 0,
      weightCertifications: (json['weightCertifications'] as List<dynamic>?)
          ?.map((e) => UserWeightCrtifiDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      certifiedUsers: (json['certifiedUsers'] as List<dynamic>?)
          ?.map((e) => CertifiUserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
