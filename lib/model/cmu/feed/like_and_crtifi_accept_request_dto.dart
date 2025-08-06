class LikeAndCrtifiRequestDto {
  final int userId;
  final int feedId;
  final int feedWriterUserId;

  LikeAndCrtifiRequestDto({
    required this.userId, 
    required this.feedId,
    required this.feedWriterUserId,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'cmuId': feedId,
        'feedWriterUserId': feedWriterUserId,
      };
}
