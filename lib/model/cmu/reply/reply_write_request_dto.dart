class ReplyWriteRequestDto {
  final int? id; // 댓글 ID (nullable, optional when creating)
  final int cmuId; // 게시글 ID
  final int? userId; // 작성자 ID
  final String ctnt; // 내용
  final int? parentReplyId; // 부모 댓글 ID (null이면 일반 댓글)

  ReplyWriteRequestDto({
    this.id,
    required this.cmuId,
    this.userId,
    required this.ctnt,
    this.parentReplyId,
  });

  // JSON 직렬화용 toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cmuId': cmuId,
      'userId': userId,
      'ctnt': ctnt,
      'parentReplyId': parentReplyId,
    };
  }

  // JSON 역직렬화용 fromJson (선택적으로 사용)
  factory ReplyWriteRequestDto.fromJson(Map<String, dynamic> json) {
    return ReplyWriteRequestDto(
      id: json['id'],
      cmuId: json['cmuId'],
      userId: json['userId'],
      ctnt: json['ctnt'],
      parentReplyId: json['parentReplyId'],
    );
  }
}
