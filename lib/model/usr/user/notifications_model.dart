import 'package:drift/drift.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final int? feedId;
  final String? type;
  final String receivedAt;
  final String isRead; // 'true' or 'false'

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.feedId,
    this.type,
    required this.receivedAt,
    required this.isRead,
  });

  /// Drift QueryRow → Model 매핑
  factory NotificationModel.fromRow(QueryRow row) {
    return NotificationModel(
      id: row.read<int>('id'),
      title: row.read<String>('title'),
      body: row.read<String>('body'),
      feedId: row.read<int?>('feed_id'),
      type: row.read<String?>('type'),
      receivedAt: row.read<String>('received_at'),
      isRead: row.read<String>('is_read'),
    );
  }
}
