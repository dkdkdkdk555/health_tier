class ReportRequestDto {
  final int cmuId;
  final String reason;

  ReportRequestDto({
    required this.cmuId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'cmuId': cmuId,
    'reason': reason,
  };
}
