import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/main.dart';
import 'package:my_app/model/cmu/feed/report_request_dto.dart';
import 'package:my_app/providers/feed_cud_providers.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/providers/notifier_provider.dart';
import 'package:my_app/service/feed_cud_api_service.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed.dart';

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
    _myUserId = UserPrefs.myUserId;
  }

   void _showReportDialog(FeedCudService? feedCudServiceInstance) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0), // 제목 패딩 조정
          contentPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0.0), // 내용 패딩 조정

          title: const Text(
            '신고 사유를 입력해주세요', // 제목 문구 변경
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center, // 제목 중앙 정렬
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10), // 제목과 텍스트 필드 사이 여백
              TextField(
                controller: reasonController,
                maxLines: 5, // 여러 줄 입력 가능하도록 maxLines 늘림
                minLines: 3, // 최소 3줄 보이도록 설정
                maxLength: 200, // 최대 글자 수 제한 (선택 사항)
                decoration: InputDecoration(
                  hintText: '자세한 신고 사유를 작성해주세요.', // 힌트 텍스트 변경
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50], // 배경색 추가
                  border: OutlineInputBorder( // 얇은 테두리
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none, // 테두리 없음
                  ),
                  focusedBorder: OutlineInputBorder( // 포커스 시 테두리 색상
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder( // 기본 테두리 색상
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // 내부 패딩
                ),
                cursorColor: Theme.of(context).primaryColor, // 커서 색상
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(15), // 액션 버튼 패딩
          actions: [
            Row( // 버튼들을 가로로 정렬
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 버튼들 사이 공간 균등 분배
              children: [

                const SizedBox(width: 10), // 버튼 사이 간격
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('신고 사유를 입력해주세요.')),
                        );
                        return;
                      }

                      String? message;
                      String? errorMessage;

                      try {
                        final reportDto = ReportRequestDto(
                          cmuId: widget.feedId,
                          reason: reason,
                        );
                        message = await feedCudServiceInstance!.reportFeed(reportDto);
                      } catch (e) {
                        errorMessage = e.toString().replaceAll('Exception: ', '');
                      }

                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);

                      if (!context.mounted) return;

                      if (message != null) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            title: const Text('신고 완료', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Text(message.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('확인'),
                              ),
                            ],
                          ),
                        );
                      } else if (errorMessage != null) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            title: const Text('신고 실패', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Text(errorMessage.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('닫기'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // 버튼 배경색
                      foregroundColor: Colors.white, // 텍스트 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // 버튼 모서리 둥글게
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0, // 그림자 제거
                    ),
                    child: const Text(
                      '신고하기', // 버튼 텍스트 변경
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 햄버거 아이콘 클릭 시 바텀 시트를 보여주는 함수
  void _showActionBottomSheet(FeedCudService? feedCudService) {
    final feedWriterUserId = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.userId));
    final bool isMyPost = _myUserId != null && _myUserId == feedWriterUserId;

    final feedCategoryId = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.categoryId));
    final bool isCrtifiCategory = feedCategoryId == 2 ? true : feedCategoryId==3 ? true : false;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞게 높이 조절
              children: <Widget>[
                if (isMyPost) // 내 게시글인 경우
                  if(!isCrtifiCategory)
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
                      _showReportDialog(feedCudService);
                    },
                  ),
                // 바텀 시트 하단에 여백을 추가하여 UI를 더 보기 좋게 만들 수 있습니다.
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedCudServiceAsyncValue = ref.watch(feedCudServiceProvider); // <-- FutureProvider를 watch

    // 서비스 인스턴스가 로딩 중이거나 에러 상태인지 확인합니다.
    final bool isServiceLoadingOrError = feedCudServiceAsyncValue.isLoading || feedCudServiceAsyncValue.hasError;
    final bool canSubmit = !isServiceLoadingOrError;

    final FeedCudService? feedCudService = canSubmit ? feedCudServiceAsyncValue.valueOrNull : null;

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
                onTap: () {
                  _showActionBottomSheet(feedCudService);
                },
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