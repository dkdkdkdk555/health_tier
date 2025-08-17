
class UserSimpleDto {
  final String nickname;
  final String? imgPath;
  final SnsType? snsType;

  UserSimpleDto({
    required this.nickname,
    this.imgPath,
    this.snsType,
  });

  factory UserSimpleDto.fromJson(Map<String, dynamic> json) {
    return UserSimpleDto(
      nickname: json['nickname'],
      imgPath: json['imgPath'],
      snsType: _snsTypeFromString(json['snsType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'imgPath': imgPath,
      'snsType': snsType?.name,
    };
  }

  static SnsType? _snsTypeFromString(String? type) {
    if (type == null) return null;
    switch (type.toLowerCase()) {
      case 'kakao':
        return SnsType.kakao;
      case 'naver':
        return SnsType.naver;
      case 'apple':
        return SnsType.apple;
      default:
        return null; // 예상 못 한 값일 때 안전하게 null 처리
    }
  }
}

enum SnsType {
  kakao("카카오"),
  naver("네이버"),
  apple("애플");

  final String displayName; // value 역할

  const SnsType(this.displayName);
}