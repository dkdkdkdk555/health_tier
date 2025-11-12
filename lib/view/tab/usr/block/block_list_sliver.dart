import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/usr/user/notifications_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/notifier_provider.dart' show notificationNumsNotifierProvider;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/util/user_prefs.dart' show UserPrefs;
import 'package:my_app/view/common/error_widget.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail.dart';
import 'package:my_app/view/tab/usr/notification/notification_item.dart';
import 'package:my_app/view/tab/usr/usr_main.dart';

class BlockListSliver extends ConsumerStatefulWidget {
  const BlockListSliver({super.key});

  @override
  ConsumerState<BlockListSliver> createState() => _BlockListSliverState();
}

class _BlockListSliverState extends ConsumerState<BlockListSliver> {
  List<NotificationModel> _notifications = [];

  late int loginUserId;
  @override
  void initState() {
    super.initState();
    loginUserId = UserPrefs.myUserId!;
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(selectAllNotifications(loginUserId));

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
                  ref.invalidate(hasUnreadNotification);
                }
              });
              
              return Slidable(
                key: ValueKey(notification.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        await deleteNotification(ref: ref, id: notification.id);
                        
                        if (!mounted) return;
                        setState(() {
                          _notifications.removeAt(index);
                        });

                        ref.invalidate(selectAllNotifications);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: '삭제',
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    final notifiType = notification.type;
                    if(notifiType != null && 
                        (notifiType == 'COMMUNITY' || notifiType == 'CRTIFI')
                    ) {
                      context.push('/cmu/feed/${notification.feedId!}?isFromNotifi=true');
                    } else if(notifiType == 'BADGE') {
                      context.go('/usr/info');
                    }
                  },
                  child: NotificationItem(notification: notification)
                ),
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
            child: AppLoadingIndicator(),
          ),
        ),
      ),
      error: (err, stack) => const SliverToBoxAdapter(
        child: ErrorContentWidget(mainText: '알림을 불러오는 중 오류가 발생했습니다.',)
      ),
    );
  }
}
