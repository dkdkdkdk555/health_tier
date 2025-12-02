class FeedReportModel {
  int reportId;
  int cmuId;
  int reporterId;
  String reporterNickname;
  String reason;
  String status;
  String title; // 
  String ctntPreview; //
  int writerId;
  String writerNickname;
  String createDttm;

  FeedReportModel({
    required this.reportId,
    required this.cmuId,
    required this.reporterId,
    required this.reporterNickname,
    required this.reason,
    required this.status,
    required this.title,
    required this.ctntPreview,
    required this.writerId,
    required this.writerNickname,
    required this.createDttm,
  });

  factory FeedReportModel.fromJson(Map<String, dynamic> json) {
    return FeedReportModel(
      reportId: json['reportId'] ?? 0,
      cmuId: json['cmuId'] ?? 0,
      reporterId: json['reporterId'] ?? 0,
      reporterNickname: json['reporterNickname'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      title: json['title'] ?? '',
      ctntPreview: json['ctntPreview'] ?? '',
      writerId: json['writerId'] ?? 0,
      writerNickname: json['writerNickname'] ?? '',
      createDttm: json['createDttm'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'cmuId': cmuId,
      'reporterId': reporterId,
      'reporterNickname': reporterNickname,
      'reason': reason,
      'status': status,
      'title': title,
      'ctntPreview': ctntPreview,
      'writerId': writerId,
      'writerNickname': writerNickname,
      'createDttm': createDttm,
    };
  }
}
