import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/notifier/feed_main_change_notifier.dart';
import 'package:my_app/notifier/notification_nums_notifier.dart';
import 'package:my_app/notifier/reply_supply_notifier.dart';

// 피드 상세 와 댓글 조회 간 데이터공유
final feedMainChangeNotifierProvider = ChangeNotifierProvider<FeedMainChangeNotifier>((ref) {
  return FeedMainChangeNotifier();
});

// 답글 입력시 부모 댓글의 내용 등을 전달할 목적
final replySupplyNotifierProvider = ChangeNotifierProvider<ReplySupplyNotifier>((ref) {
  return ReplySupplyNotifier();
});

final notificationNumsNotifierProvider = ChangeNotifierProvider<NotificationNumsNotifier>((ref) {
  return NotificationNumsNotifier();
});