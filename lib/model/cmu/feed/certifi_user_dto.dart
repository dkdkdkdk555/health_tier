class CertifiUserDto {
  final int userId;
  final String nickname;
  final String? imgPath;

  CertifiUserDto({
    required this.userId,
    required this.nickname,
    required this.imgPath,
  });

  factory CertifiUserDto.fromJson(Map<String, dynamic> json) {
    return CertifiUserDto(
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      imgPath: json['imgPath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'imgPath': imgPath,
    };
  }
}