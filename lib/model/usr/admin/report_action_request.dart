class ReportActionRequest {
  int reportId;
  String action; // 유지, 경고, 삭제
  String? reason; // 삭제 사유 (삭제일 때만 사용)

  ReportActionRequest({
    required this.reportId,
    required this.action,
    this.reason,
  });

  factory ReportActionRequest.fromJson(Map<String, dynamic> json) {
    return ReportActionRequest(
      reportId: json['reportId'] ?? 0,
      action: json['action'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'action': action,
      'reason': reason,
    };
  }
}
