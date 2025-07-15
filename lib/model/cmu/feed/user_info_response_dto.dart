import 'badge_info_dto.dart';

class UserInfoResponseDto {
  final String nickname;
  final String? imgPath;
  final String? createDttm;
  final List<BadgeInfoDto> badges;

  UserInfoResponseDto({
    required this.nickname,
    this.imgPath,
    this.createDttm,
    required this.badges,
  });

  factory UserInfoResponseDto.fromJson(Map<String, dynamic> json) {
    return UserInfoResponseDto(
      nickname: json['nickname'],
      imgPath: json['imgPath'],
      createDttm: json['createDttm'],
      badges: (json['badges'] as List<dynamic>)
          .map((e) => BadgeInfoDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'imgPath': imgPath,
      'createDttm': createDttm,
      'badges': badges.map((e) => e.toJson()).toList(),
    };
  }
}
