import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';
import 'package:my_app/view/tab/usr/block/block_list_sliver.dart';
import 'package:my_app/view/tab/usr/block/block_manage_app_bar_delegatte.dart';

class BlockManagePage extends StatefulWidget {
  const BlockManagePage({super.key});

  @override
  State<BlockManagePage> createState() => _BlockManagePageState();
}

class _BlockManagePageState extends State<BlockManagePage> {

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
            delegate: BlockManageAppBarDelegatte(),
          ),
          const BlockListSliver()
        ],
      ),
    );
  }
}