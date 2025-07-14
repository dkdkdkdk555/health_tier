import 'badge_info_dto.dart';

class UserInfoResponseDto {
  final String nickname;
  final String? imgPath;
  final List<BadgeInfoDto> badges;

  UserInfoResponseDto({
    required this.nickname,
    this.imgPath,
    required this.badges,
  });

  factory UserInfoResponseDto.fromJson(Map<String, dynamic> json) {
    return UserInfoResponseDto(
      nickname: json['nickname'],
      imgPath: json['imgPath'],
      badges: (json['badges'] as List<dynamic>)
          .map((e) => BadgeInfoDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'imgPath': imgPath,
      'badges': badges.map((e) => e.toJson()).toList(),
    };
  }
}
