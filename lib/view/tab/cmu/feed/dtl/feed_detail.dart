import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_app_bar_delegate.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply_bottom_bar.dart';

class FeedDetail extends StatelessWidget {
  final int feedId;
  const FeedDetail({
    super.key,
    required this.feedId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // 상단 앱바
          SliverPersistentHeader(
            pinned: true,
            delegate: FeedDetailAppBarDelegate(),
          ),

          // 🔷 게시글 본문
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: EdgeInsets.all(16.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           '게시글 제목',
          //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          //         ),
          //         SizedBox(height: 8),
          //         Text('작성자 | 날짜'),
          //         SizedBox(height: 16),
          //         Text('여기에 본문 내용이 들어갑니다.'),
          //         SizedBox(height: 16),
          //         // 이미지, 태그 등 추가 가능
          //       ],
          //     ),
          //   ),
          // ),

          // 🔷 댓글 리스트
          // SliverList(
            // delegate: SliverChildBuilderDelegate(
            //   (context, index) {
            //     return ListTile(
            //       title: Text(comments[index]),
            //     );
            //   },
            //   childCount: comments.length,
            // ),
          // ),

          // 🔷 하단 여백 (필요시)
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
      bottomNavigationBar: const ReplyBottomBar(),
    );
  }
}
