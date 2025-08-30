import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';
import 'package:my_app/view/tab/usr/notification/notification_header.dart';
import 'package:my_app/view/tab/usr/notification/notification_list_sliver.dart';
import 'package:my_app/view/tab/usr/notification/notification_manage_app_bar_delegatte.dart'; // NotificationModel 포함

class NotificationManagePage extends StatefulWidget {
  const NotificationManagePage({super.key});

  @override
  State<NotificationManagePage> createState() => _NotificationManagePageState();
}

class _NotificationManagePageState extends State<NotificationManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상단바 위 여백
          const TopBlankArea(),
          // 상단바
          SliverPersistentHeader(
            pinned: true,
            delegate: NotificationManageAppBarDelegatte(),
          ),
          // 알림 헤더
          const SliverToBoxAdapter(
            child: NotificationHeader()
          ),
          // 알림 목록
          const NotificationListSliver()
        ],
      ),
    );
  }
}