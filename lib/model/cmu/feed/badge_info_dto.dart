class BadgeInfoDto {
  final String badgeId;
  final String badgeName;
  final String badgeType;
  final String? badgeCtnt;

  BadgeInfoDto({
    required this.badgeId,
    required this.badgeName,
    required this.badgeType,
    this.badgeCtnt,
  });

  factory BadgeInfoDto.fromJson(Map<String, dynamic> json) {
    return BadgeInfoDto(
      badgeId: json['badgeId'],
      badgeName: json['badgeName'],
      badgeType: json['badgeType'],
      badgeCtnt: json['badgeCtnt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'badgeName': badgeName,
      'badgeType': badgeType,
      'badgeCtnt': badgeCtnt,
    };
  }
}
