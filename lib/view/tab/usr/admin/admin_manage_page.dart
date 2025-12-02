import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';
import 'package:my_app/view/tab/usr/management/doc_backup_and_restore.dart' show ModernButtonCard;

class AdminManagePage extends StatefulWidget {
  const AdminManagePage({super.key});

  @override
  State<AdminManagePage> createState() => _AdminManagePageState();
}

class _AdminManagePageState extends State<AdminManagePage> {

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상단바 위 여백
          const TopBlankArea(),
          // 상단바
          const SliverToBoxAdapter(
            child: CmuBasicAppBar(centerText: '관리자 신고 관리',)
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                spacing: 8*htio,
                children: [
                  ModernButtonCard(
                    htio: htio,
                    wtio: wtio,
                    icon: Icons.feed_outlined,
                    title: '피드 신고관리',
                    subtitle: '신고된 피드의 처리여부를 결정합니다.',
                    color: Colors.blue.shade100,
                    onTap: () async {
                    }
                  ),
                  ModernButtonCard(
                    htio: htio,
                    wtio: wtio,
                    icon: Icons.message_outlined,
                    title: '댓글 신고관리',
                    subtitle: '신고된 댓글의 처리여부를 결정합니다.',
                    color: Colors.amber.shade100,
                    onTap: () async {
                    }
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}