import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/main.dart';
import 'package:my_app/model/cmu/feed/report_request_dto.dart';
import 'package:my_app/providers/feed_cud_providers.dart';
import 'package:my_app/providers/notifier_provider.dart';
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/service/feed_cud_api_service.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/error_message_utils.dart';
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

  void _showReportDialog(FeedCudService? feedCudServiceInstance) async {
    final reason = await showInputDialog(
      context,
      title: "신고 사유를 입력해주세요",
      hintText: "자세한 신고 사유를 작성해주세요.",
      confirmText: "신고하기",
      cancelText: "취소",
      minLines: 3,
      maxLines: 5,
      maxLength: 200,
    );

    if (reason != null) {
      try {
        final reportDto = ReportRequestDto(cmuId: widget.feedId, reason: reason);
        final response = await feedCudServiceInstance!.reportFeed(reportDto);

        if (!mounted) return;
        if (response == 'success') {
          showAppDialog(context, message: "신고가 접수되었습니다.", confirmText: "확인");
        }
      } catch (e) {
        if (!mounted) return;
        showAppDialog(context,message: "신고에 실패했습니다.\n관리자에게 문의하세요.",confirmText: "확인",);
      }
    }
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
                      context.push('/cmu/writeFeed', extra: widget.feedId);
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
                    onTap: () async {
                      final response = await ref.read(jwtTokenVerificationProvider.future);
                      if(response.isValid) {
                        if(!context.mounted)return;
                        Navigator.pop(context); // 바텀 시트 닫기
                        _showReportDialog(feedCudService);
                      } else {
                        if(!context.mounted)return;
                        showAppMessage(context,title: '로그인이 필요해요', message: '로그인이 필요한 기능입니다. 로그인 후 이용해주세요.', type: AppMessageType.dialog, loginRequest: true);
                      }
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
                // WriteFeed에서 왔으면 뒤로가기 대신 CmuMain() 으로 보내야 하므로 이전 스택을 날리면서 지정한 라우트로 이동
                context.replace('/cmu');
              } else {
                context.pop();
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