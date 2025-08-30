import 'package:flutter/material.dart';
import 'package:my_app/view/tab/usr/notification/notification_manage_app_bar.dart';

class NotificationManageAppBarDelegatte extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const NotificationManageAppBar(centerText: '알림',);
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

}