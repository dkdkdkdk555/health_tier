import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/main.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 임포트

class FeedDetailAppBar extends ConsumerStatefulWidget {
  const FeedDetailAppBar({
    super.key,
    required this.feedId,
    this.isFromWriteFeed = false,
  });

  final bool isFromWriteFeed;
  final int feedId;

  @override
  ConsumerState<FeedDetailAppBar> createState() => _FeedDetailAppBarState();
}

class _FeedDetailAppBarState extends ConsumerState<FeedDetailAppBar> {
  // 현재 로그인한 사용자의 ID를 저장할 변수
  int? _myUserId;

  @override
  void initState() {
    super.initState();
    _loadMyUserId(); // 위젯 초기화 시 사용자 ID 로드
  }

  // SharedPreferences에서 현재 로그인한 사용자 ID를 로드하는 함수
  Future<void> _loadMyUserId() async {
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _myUserId = prefs.getInt('myUserId'); // 'myUserId' 키로 저장된 사용자 ID 가져오기
    //   debugPrint('Loaded myUserId from SharedPreferences: $_myUserId');
    // });
    _myUserId = 30;
  }

  // 햄버거 아이콘 클릭 시 바텀 시트를 보여주는 함수
  void _showActionBottomSheet() {
    final feedWriterUserId = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.userId));
    final bool isMyPost = _myUserId != null && _myUserId == feedWriterUserId;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞게 높이 조절
            children: <Widget>[
              if (isMyPost) // 내 게시글인 경우
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('수정하기'),
                  onTap: () {
                    Navigator.pop(context); // 바텀 시트 닫기
                    // WriteFeed 화면으로 이동하며 feedId 전달
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WriteFeed(feedId: widget.feedId),
                      ),
                    );
                    debugPrint('게시글 수정 화면으로 이동, Feed ID: ${widget.feedId}');
                  },
                ),
              if (isMyPost) // 내 게시글인 경우
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('삭제하기'),
                  onTap: () {
                    Navigator.pop(context); // 바텀 시트 닫기
                    // TODO: 게시글 삭제 로직 실행
                    debugPrint('게시글 삭제');
                  },
                ),
              if (!isMyPost) // 내 게시글이 아닌 경우
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('신고하기'),
                  onTap: () {
                    Navigator.pop(context); // 바텀 시트 닫기
                    // TODO: 게시글 신고 로직 실행
                    debugPrint('게시글 신고');
                  },
                ),
              // 바텀 시트 하단에 여백을 추가하여 UI를 더 보기 좋게 만들 수 있습니다.
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측 아이콘
          GestureDetector(
            onTap: () {
              if (widget.isFromWriteFeed) {
                // WriteFeed에서 왔으면 CmuMain으로 이동하면서 이전 스택 모두 제거
                // MyApp은 메인 위젯으로, mvIndex를 통해 CmuMain 탭으로 이동시킬 수 있다고 가정
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MyApp(mvIndex: 2,)),
                  (Route<dynamic> route) => false, // 이전 모든 라우트 제거
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                'assets/icons/feed_detail/ico_back.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),

          // 우측 아이콘 묶음
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/feed_detail/ico_share.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 16),
              // 햄버거 아이콘 클릭 시 _showActionBottomSheet 호출
              GestureDetector(
                onTap: _showActionBottomSheet,
                child: SvgPicture.asset(
                  'assets/icons/feed_detail/ico_hamberger.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}