import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/srch/srch_app_bar_delegate.dart';

class CmuTotalSrch extends StatefulWidget {
  const CmuTotalSrch({super.key});

  @override
  State<CmuTotalSrch> createState() => _CmuTotalSrchState();
}

class _CmuTotalSrchState extends State<CmuTotalSrch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상단바 위 여백
          SliverAppBar(
            pinned: true,
            primary: false,
            toolbarHeight: 44,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(color: Colors.white),
            )
          ),
          // 상단바
          SliverPersistentHeader(
            pinned: true,
            delegate: SrchAppBarDelegate(),
          ),
          // 최근검색어

          // 검색결과(글 목록)
        ],
      ),
    );
  }
}