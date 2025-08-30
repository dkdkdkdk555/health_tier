import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/notifier_provider.dart' show notificationNumsNotifierProvider;
import 'package:my_app/view/tab/usr/notification/notification_item.dart';

class NotificationListSliver extends ConsumerStatefulWidget {
  const NotificationListSliver({super.key});

  @override
  ConsumerState<NotificationListSliver> createState() => _NotificationListSliverState();
}

class _NotificationListSliverState extends ConsumerState<NotificationListSliver> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(selectAllNotifications);

    return notificationsAsync.when(
      data: (notifications) {

        final unreadCount = notifications.where((notification) => notification.isRead == 'false').length;
        Future.microtask((){ // 안 읽은 알림 갯수 알림!
            ref.read(notificationNumsNotifierProvider).changeNum(unreadCount);
        });

        if (notifications.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  '알림이 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }

        final reversedNotifications = notifications.reversed.toList();
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final notification = reversedNotifications[index];
              return NotificationItem(notification: notification);
            },
            childCount: notifications.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '알림을 불러오는 중 오류가 발생했습니다.',
              style: TextStyle(color: Colors.grey[600],),
            ),
          ),
        ),
      ),
    );
  }
}
