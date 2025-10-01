class LikeAndCrtifiRequestDto {
  final int userId;
  final int cmuId;
  final int feedWriterUserId;
  final String? nickname;

  LikeAndCrtifiRequestDto({
    required this.userId, 
    required this.cmuId,
    required this.feedWriterUserId,
    this.nickname,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'cmuId': cmuId,
        'feedWriterUserId': feedWriterUserId,
        'nickname' : nickname,
      };
}
