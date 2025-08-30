import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/db_providers.dart'; // NotificationModel 포함

class NotificationManagePage extends ConsumerStatefulWidget {
  const NotificationManagePage({super.key});

  @override
  ConsumerState<NotificationManagePage> createState() => _NotificationManagePageState();
}

class _NotificationManagePageState extends ConsumerState<NotificationManagePage> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(selectAllNotifications);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 관리'),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('알림이 없습니다.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              // 각 필드별 출력
              debugPrint('--- Notification ${index + 1} ---');
              debugPrint('ID: ${notification.id}');
              debugPrint('Title: ${notification.title}');
              debugPrint('Body: ${notification.body}');
              debugPrint('FeedId: ${notification.feedId}');
              debugPrint('Type: ${notification.type}');
              debugPrint('ReceivedAt: ${notification.receivedAt}');
              debugPrint('IsRead: ${notification.isRead}');
              debugPrint('-----------------------');

              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.body),
                trailing: Text(
                  notification.isRead == 'true' ? '읽음' : '안읽음',
                  style: TextStyle(
                    color: notification.isRead == 'true' ? Colors.grey : Colors.blue,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러: $err')),
      ),
    );
  }
}