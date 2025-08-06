class ReplyLikeRequestDto {
  final int userId;
  final int replyId;

  ReplyLikeRequestDto({
    required this.userId, 
    required this.replyId,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'replyId': replyId,
      };
}
