class PushTokenRequest {
  final String fcmToken;
  final String osType;
  final String? installationId;

  PushTokenRequest({
    required this.fcmToken,
    required this.osType,
    required this.installationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fcmToken': fcmToken,
      'osType': osType,
      'installationId': installationId,
    };
  }
}
