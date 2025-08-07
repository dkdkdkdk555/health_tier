class ReportRequestDto {
  final int? cmuId;
  final int? replyId;
  final String reason;

  ReportRequestDto({
    this.cmuId,
    this.replyId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'cmuId': cmuId,
    'replyId': replyId,
    'reason': reason,
  };
}
