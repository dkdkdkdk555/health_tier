import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/extension/cmu_invalidate_collect.dart';
import 'package:my_app/providers/user_cud_providers.dart' show userCudServiceProvider;
import 'package:my_app/service/user_api_service.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/screen_ratio.dart';
import 'package:my_app/util/user_prefs.dart' show UserPrefs;

class CmuUsrDetailAppBar extends ConsumerStatefulWidget {
  final String centerText;
  final int userId;
  const CmuUsrDetailAppBar({
    super.key,
    required this.centerText,
    required this.userId
  });

  @override
  ConsumerState<CmuUsrDetailAppBar> createState() => _CmuBasicAppBarState();
}

class _CmuBasicAppBarState extends ConsumerState<CmuUsrDetailAppBar> {
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

  void _showActionBottomSheet(UserApiService? userService){
    final parentContext = context;
    showModalBottomSheet(
      context: parentContext,
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
                  ListTile(
                    leading: Icon(Icons.block, color: Colors.red.shade600,),
                    title: Text('차단하기', style: TextStyle(
                      color: Colors.red.shade600
                    ),),
                    onTap: () async {
                      await showAppDialog(context, message: '사용자를 차단 하시겠습니까?', 
                        confirmText: '확인',
                        cancelText: '취소',
                        onCancel: () {
                          Navigator.pop(context); // 바텀 시트 닫기
                        },
                        onConfirm: () async {
                          final response = await userService?.blockUser(widget.userId);
                          if (!context.mounted) return;
                          if (response == 'success') {
                            Navigator.pop(context);
                            if (!context.mounted) return;
                            CmuInvalidateCollect().cmuOnlyInvalidateCache(ref); // 커뮤 캐시 삭제
                            await showAppDialog(parentContext, message: "사용자를 차단하였습니다.", confirmText: "확인");
                            if (!parentContext.mounted) return;
                            parentContext.go('/cmu');
                          }
                        }
                      );
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
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    final userServiceAsyncValue = ref.watch(userCudServiceProvider);

     // 서비스 인스턴스가 로딩 중이거나 에러 상태인지 확인합니다.
    final bool isServiceLoadingOrError = userServiceAsyncValue.isLoading || userServiceAsyncValue.hasError;
    final bool canSubmit = !isServiceLoadingOrError;

    final UserApiService? userService = canSubmit ? userServiceAsyncValue.valueOrNull : null;

    return Container(
      width: 375 * wtio,
      padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 10 * htio),
      color: Colors.white,
      height: 48 * htio,
      child: Stack(
        children: [
          // 가운데 텍스트
          Center(
            child: Text(
              widget.centerText,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18 * htio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1 * htio,
              ),
            ),
          ),

          // 왼쪽 뒤로가기 버튼
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: SizedBox(
                width: 24 * wtio,
                height: 24 * wtio,
                child: SvgPicture.asset(
                  'assets/icons/feed_detail/ico_back.svg',
                  width: 24 * wtio,
                  height: 24 * wtio,
                ),
              ),
            ),
          ),
          if(_myUserId!=widget.userId) // 나의 이용자 상세정보에서는 나오지 않게하기
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () async{
                _showActionBottomSheet(userService);
              },
              child: SvgPicture.asset(
                'assets/icons/feed_detail/ico_hamberger.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
