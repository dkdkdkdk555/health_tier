class ReplyReportModel {
  int reportId;
  int cmuId;
  int replyId; //
  int reporterId;
  String reporterNickname;
  String reason;
  String status;
  String replyCtnt; //
  int writerId;
  String writerNickname;
  String createDttm;

  ReplyReportModel({
    required this.reportId,
    required this.cmuId,
    required this.replyId,
    required this.reporterId,
    required this.reporterNickname,
    required this.reason,
    required this.status,
    required this.replyCtnt,
    required this.writerId,
    required this.writerNickname,
    required this.createDttm,
  });

  factory ReplyReportModel.fromJson(Map<String, dynamic> json) {
    return ReplyReportModel(
      reportId: json['reportId'] ?? 0,
      cmuId: json['cmuId'] ?? 0,
      replyId: json['replyId'] ?? 0,
      reporterId: json['reporterId'] ?? 0,
      reporterNickname: json['reporterNickname'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      replyCtnt: json['replyCtnt'] ?? '',
      writerId: json['writerId'] ?? 0,
      writerNickname: json['writerNickname'] ?? '',
      createDttm: json['createDttm'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'cmuId': cmuId,
      'replyId': replyId,
      'reporterId': reporterId,
      'reporterNickname': reporterNickname,
      'reason': reason,
      'status': status,
      'replyCtnt': replyCtnt,
      'writerId': writerId,
      'writerNickname': writerNickname,
      'createDttm': createDttm,
    };
  }
}
