class BadgeInfoDto {
  final String badgeId;
  final String badgeName;
  final String badgeType;

  BadgeInfoDto({
    required this.badgeId,
    required this.badgeName,
    required this.badgeType,
  });

  factory BadgeInfoDto.fromJson(Map<String, dynamic> json) {
    return BadgeInfoDto(
      badgeId: json['badgeId'],
      badgeName: json['badgeName'],
      badgeType: json['badgeType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'badgeName': badgeName,
      'badgeType': badgeType,
    };
  }
}
