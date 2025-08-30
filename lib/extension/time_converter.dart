import 'package:intl/intl.dart';

class TimeConverter {
  /// ISO8601 문자열을 받아서 "방금 전", "n분 전", "n시간 전", "n일 전" 또는 "yyyy-MM-dd" 형식으로 변환
  static String convertDisplayTime(String receivedAt) {
    final createDttm = DateTime.parse(receivedAt);
    final now = DateTime.now();
    final duration = now.difference(createDttm);

    final minutes = duration.inMinutes;
    final hours = duration.inHours;
    final days = duration.inDays;

    if (minutes < 5) {
      return '방금 전';
    } else if (minutes < 60) {
      return '$minutes분 전';
    } else if (hours < 24) {
      return '$hours시간 전';
    } else if (days < 30) {
      return '$days일 전';
    } else {
      return DateFormat('yyyy-MM-dd').format(createDttm);
    }
  }
}