import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/usr/user/notifications_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/notifier_provider.dart' show notificationNumsNotifierProvider;
import 'package:my_app/view/tab/usr/notification/notification_item.dart';

class NotificationListSliver extends ConsumerStatefulWidget {
  const NotificationListSliver({super.key});

  @override
  ConsumerState<NotificationListSliver> createState() => _NotificationListSliverState();
}

class _NotificationListSliverState extends ConsumerState<NotificationListSliver> {
  List<NotificationModel> _notifications = [];

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(selectAllNotifications);

    return notificationsAsync.when(
      data: (notifications) {

        // 로컬 리스트 초기화
        if (_notifications.isEmpty) _notifications = notifications.reversed.toList();

        final unreadCount = notifications.where((notification) => notification.isRead == 'false').length;
        Future.microtask((){ // 안 읽은 알림 갯수 알림!
            ref.read(notificationNumsNotifierProvider).changeNum(unreadCount);
        });

        if (_notifications.isEmpty) {
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

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final notification = _notifications[index];

              // 알림 읽음 처리
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (notification.isRead == 'false') {
                  markNotificationRead(ref: ref, id: notification.id);
                }
              });
              
              return Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                    // DB에서 삭제
                    await deleteNotification(ref: ref, id: notification.id,);

                    // 로컬 리스트에서 즉시 제거
                    setState(() {
                      _notifications.removeAt(index);
                    });

                    // unreadCount 갱신
                    final unreadCount = _notifications.where((n) => n.isRead == 'false').length;
                    ref.read(notificationNumsNotifierProvider).changeNum(unreadCount);

                    // selectAllNotifications 재빌드
                    ref.invalidate(selectAllNotifications);
                },
                child: NotificationItem(notification: notification),
              );
            },
            childCount: _notifications.length,
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
