import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart' show CmuBasicAppBar;
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';
import 'package:my_app/view/tab/usr/admin/report_list_sliver.dart';
import 'package:my_app/view/tab/usr/block/block_list_sliver.dart';

class AdminManageList extends StatefulWidget {
  final String topic;
  const AdminManageList({
    required this.topic,
    super.key
  });

  @override
  State<AdminManageList> createState() => _AdminManageListState();
}

class _AdminManageListState extends State<AdminManageList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상단바 위 여백
          const TopBlankArea(),
          // 상단바
          SliverToBoxAdapter(
            child: CmuBasicAppBar(centerText: '${widget.topic == 'feed' ? '피드' : '댓글'} 신고관리',)
          ),
          // 신고목록
          ReportListSliver(topic: widget.topic,)
        ],
      ),
    );
  }
}