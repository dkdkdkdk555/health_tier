import 'dart:convert';

class UsrLeaveRequest {
  final String reason;
  final String? reasonDetail;

  UsrLeaveRequest({
    required this.reason,
    this.reasonDetail,
  });

  Map<String, dynamic> toJson() {
    return {
      "reason": reason,
      "reasonDetail": reasonDetail,
    };
  }

  String toRawJson() => json.encode(toJson());
}
