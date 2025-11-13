class HtUserBlockDto {
  final int id;
  final int userId;
  final int blockedUserId;
  final String? createDttm;
  final String? blockedUserImgPath;
  final String? blockedUserNickname;

  HtUserBlockDto({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    required this.createDttm,
    this.blockedUserImgPath,
    this.blockedUserNickname,
  });

  factory HtUserBlockDto.fromJson(Map<String, dynamic> json) {
    return HtUserBlockDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      blockedUserId: json['blockedUserId'] as int,
      createDttm: json['createDttm'] as String?,
      blockedUserImgPath: json['blockedUserImgPath'] as String?,
      blockedUserNickname: json['blockedUserNickname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'blockedUserId': blockedUserId,
      'createDttm': createDttm,
      'blockedUserImgPath': blockedUserImgPath,
      'blockedUserNickname': blockedUserNickname,
    };
  }

  HtUserBlockDto copyWith({
    int? id,
    int? userId,
    int? blockedUserId,
    String? createDttm,
    String? blockedUserImgPath,
    String? blockedUserNickname,
  }) {
    return HtUserBlockDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      createDttm: createDttm ?? this.createDttm,
      blockedUserImgPath: blockedUserImgPath ?? this.blockedUserImgPath,
      blockedUserNickname: blockedUserNickname ?? this.blockedUserNickname,
    );
  }

  @override
  String toString() {
    return 'HtUserBlockDto(id: $id, userId: $userId, blockedUserId: $blockedUserId, '
        'createDttm: $createDttm, blockedUserImgPath: $blockedUserImgPath, '
        'blockedUserNickname: $blockedUserNickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtUserBlockDto &&
        other.id == id &&
        other.userId == userId &&
        other.blockedUserId == blockedUserId &&
        other.createDttm == createDttm &&
        other.blockedUserImgPath == blockedUserImgPath &&
        other.blockedUserNickname == blockedUserNickname;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      blockedUserId.hashCode ^
      createDttm.hashCode ^
      blockedUserImgPath.hashCode ^
      blockedUserNickname.hashCode;
}
