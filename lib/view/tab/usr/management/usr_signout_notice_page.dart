import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/extension/cmu_invalidate_collect.dart' show CmuInvalidateCollect;
import 'package:my_app/model/usr/user/usr_leave_request.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/error_message_utils.dart' show showAppMessage;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/token_manager.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';
import 'package:my_app/view/tab/usr/get_started_screen.dart';

class UsrSignoutNoticePage extends ConsumerStatefulWidget {
  const UsrSignoutNoticePage({super.key});

  @override
  ConsumerState<UsrSignoutNoticePage> createState() => _UsrSignoutNoticePageState();
}

class _UsrSignoutNoticePageState extends ConsumerState<UsrSignoutNoticePage> {
  final List<String> reasons = [
    "서비스 이용 불편",   // 기능 부족, 사용성 불편, 앱 안정성 문제 등
    "개인 사정",         // 시간 부족, 일정 문제, 더 이상 필요 없음
    "다른 서비스 이용",   // 경쟁 서비스로 이동, 더 나은 대안 발견
    // "비용 문제",         // 유료 결제 부담, 가격 대비 만족도 부족
    "기타",
  ];
  
  int? selectedIndex; // 선택된 이유
  final TextEditingController reasonDetailController = TextEditingController();

  @override
  void dispose() {
    reasonDetailController.dispose();
    super.dispose();
  }

  bool isAgree = false; // 체크박스 상태
  var htio = 0.0;
  var wtio = 0.0;
  
  @override
  Widget build(BuildContext context) {
     htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height:44 * htio),
            const CmuBasicAppBar(centerText: '회원탈퇴',),
            Container(
              height: 1,
              decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 25,
                    children: [
                      makeTitle('유의사항'),
                      buildNoticeList(),
                      makeTitle('탈퇴 사유'),
                      buildReasonOptions(),
                      const SizedBox(height: 1,)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: isAgree,
                                checkColor: Colors.white,
                                activeColor: Colors.blue,
                                onChanged: (value) {
                                  if (selectedIndex == null) {
                                    // 라디오 버튼 선택이 안된 경우
                                    showAppMessage(context, message: '탈퇴 사유를 먼저 선택해주세요.');
                                    return; // 체크 상태 변경 방지
                                  }
                                  setState(() {
                                    isAgree = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                '위 내용을 확인하였으며 동의합니다.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Pretendard',
                                  height: 1.6,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:() async {
                            if(!isAgree) {
                              showAppMessage(context, message: '동의 여부를 체크해주세요.');
                              return;
                            }

                            await showAppDialog(
                              context, 
                              message: '정말 회원탈퇴를 하시겠습니까?',
                              confirmText: '확인',
                              cancelText: '취소',
                              onConfirm: () async {
                                final service = await ref.read(userCudServiceProvider.future);
                                final response = await service.leaveUser(
                                  UsrLeaveRequest(
                                    reason: reasons[selectedIndex!], 
                                    reasonDetail: reasonDetailController.text)
                                  );

                                if(response == 'success') {
                                  TokenManager.deleteAllTokens();
                                  CmuInvalidateCollect().cmuInvalidateCache(ref);
                                  if(!context.mounted) return;
                                  context.go('/usr/login');
                                  showAppMessage(context, message: '회원탈퇴를 완료하였습니다. 다시 또 만나요!');
                                }
                              },
                              onCancel: () {
                                return;
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '회원 탈퇴',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Pretendard',),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Align makeTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.bold,
          height: 1.6,
        ),
      ),
    );
  }

  /// 유의사항 목록
  Widget buildNoticeList() {
    final notices = [
      "현재 사용 중인 계정 정보가 삭제되며 복구할 수 없습니다.\n"
          "단, 체중·식단 등 통계탭에서 활용되는 데이터는 보존됩니다.",
      "작성한 글 및 댓글은 자동 삭제되지 않습니다.\n"
          "탈퇴 전 삭제가 필요한 활동이 있는지 반드시 확인해주세요.",
      "유료 서비스(구독, 결제 내역 등)가 남아있다면 별도 해지가 필요합니다.",
      "탈퇴 이후 동일한 연동서비스로 재가입은 가능하지만,\n"
          "이전 데이터와 연결되지 않습니다.",
      "법적 의무 보관 항목(결제/로그 기록 등)은 관련 법령에 따라 일정 기간 보관될 수 있습니다.",
    ];

    return Column(
      children: List.generate(notices.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                '${index + 1}. ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  notices[index],
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontFamily: 'Pretendard',
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 사유 선택 라디오 버튼
  Widget buildReasonOptions() {
    return Column(
      children: [
        Column(
          children: List.generate(reasons.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedIndex == index ? Colors.blue : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: selectedIndex == index
                          ? const Center(
                              child: Icon(
                                Icons.circle,
                                color: Colors.blue,
                                size: 12,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AutoSizeText(
                        reasons[index],
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15,
                          fontFamily: 'Pretendard',
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        TextField(
          controller: reasonDetailController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '상세 사유를 입력해주세요.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0D86E7),
                width: 1.5,
              ),
            ),
            focusColor:const Color(0xFF0D86E7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
