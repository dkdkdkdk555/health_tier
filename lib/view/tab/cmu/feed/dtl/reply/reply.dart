import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/providers/notifier_provider.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply_hamburger.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/cmu_usr_profile.dart';

class Reply extends ConsumerWidget {
  final ReplyResponseDto reply;
  final bool isChild;
  const Reply({
    super.key,
    required this.reply,
    required this.isChild,
  });


  void _showReplyHamburgerMenu(BuildContext context, Offset position, int writerUserId, int loginUserId) {
    if(loginUserId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
    }
    // 팝업 메뉴가 표시될 위치를 정확하게 계산
    final RelativeRect positionRect = RelativeRect.fromRect(
      position & const Size(40, 40), // 햄버거 아이콘의 대략적인 크기
      Offset.zero & MediaQuery.of(context).size, // 전체 화면 크기
    );

    showMenu<ReplyHamburgerAction>(
      context: context,
      position: positionRect,
      color: Colors.transparent,
      items: [
        ReplyHamburger(
          writerUserId: writerUserId,
          loginUserId: loginUserId,
          onEdit: () {
            // 수정 버튼 클릭 시 실행될 로직
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('수정하기 클릭됨!')),
            );
            // 여기에 실제 수정 로직(예: 수정 페이지로 이동) 구현
          },
          onDelete: () {
            // 삭제 버튼 클릭 시 실행될 로직
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('삭제하기 클릭됨!')),
            );
            // 여기에 실제 삭제 로직(예: 확인 다이얼로그 후 API 호출) 구현
          },
          onReport: () {
            // 신고 버튼 클릭 시 실행될 로직
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('신고하기 클릭됨!')),
            );
            // 여기에 실제 신고 로직(예: 신고 팝업 띄우기) 구현
          },
        ),
      ],
      // showMenu의 elevation과 semanticLabel을 필요에 따라 조절
      elevation: 0, // ReplyHamburger 자체에 그림자가 있으므로 여기서 0으로 설정
      // PopupMenuButton 스타일이 아닌 showMenu를 직접 사용하므로 shape는 ReplyHamburger에서 관리
    ).then((action) {
      // 메뉴에서 선택된 액션에 따라 추가 작업 수행 가능
      if (action != null) {
        debugPrint('Selected action: $action');
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginUserId = UserPrefs.myUserId;
    return Container(
      width: 375,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:  (reply.delYn == 'N' && reply.likeCnt >=5 )
                 ? const Color(0xFFFFF4E9)
                 : reply.delYn == 'Y'? Colors.grey.shade50 : Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileImageStack(reply.imgPath, reply.badges, context, reply.delYn!),
                  Padding(
                    padding: const EdgeInsets.only(left:8.0, right:4.5),
                    child: Text(
                      reply.nickname,
                      style: TextStyle(
                        color: reply.delYn == 'N' ? Colors.black : Colors.grey.shade700,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        height: 0.11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _buildWeightTag(reply.badges),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final feedWriterUserId = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.userId));
                  
                      return reply.userId == feedWriterUserId
                        ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: ShapeDecoration(
                            color: const Color(0x33333333),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text(
                            '작성자',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 10,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                        )
                        : Container();
                    }
                  ),
                  const Spacer(),
                  if(reply.delYn == 'N')
                  if(loginUserId != null || loginUserId != 0)
                  GestureDetector(
                    onTapUp: (TapUpDetails details) {
                      _showReplyHamburgerMenu(
                        context,
                        details.globalPosition, // 탭 발생 위치를 전달
                        reply.userId, // 댓글 작성자 ID
                        loginUserId ?? 0, // 로그인한 사용자 ID
                      );
                    },
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: SvgPicture.asset(
                        'assets/widgets/replyHambuger.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                reply.delYn == 'N' ? reply.ctnt : '삭제된 댓글입니다.',
                style: TextStyle(
                  color: reply.delYn == 'N' ? Colors.black : Colors.grey.shade700,
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  fontStyle: reply.delYn == 'N' ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 2,
                children: [
                if(reply.delYn == 'N')
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: SvgPicture.asset(
                      reply.isLiked ? 'assets/icons/liked.svg': 'assets/icons/like.svg',
                      width: 16,
                      height: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                if(reply.delYn == 'N')
                  Text(
                    '${reply.likeCnt}',
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
              if(reply.delYn == 'N')
              Padding(
                padding: const EdgeInsets.only(left:12.0),
                child: GestureDetector(
                  onTap: () {
                    ref.read(replyCommentSupplyNotifierProvider).pickReplyComment(reply.ctnt);
                  },
                  child: const Text(
                    '답글 쓰기',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                reply.displayDttm,
                style: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageStack(String imgPath, List<BadgeInfoDto>? badges, BuildContext context, String delYn) {
    final todayBadge = badges!
        .firstWhere(
          (badge) => badge.badgeType == 'today',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CmuUsrProfile(userId: reply.userId),
          ),
        );
      },
      child: SizedBox(
        width: 26,
        height: 26,
        child: Stack(
          children: [
            if (todayBadge.badgeId.isNotEmpty) // .isNotEmpty 대신 != ''
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/widgets/${todayBadge.badgeId}.svg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            Positioned(
              left: 1.09,
              top: 1.09,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: (imgPath.isNotEmpty)
                      ? delYn == 'N' ?
                          Image.network(
                            imgPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return SvgPicture.asset(
                                'assets/widgets/default_user_profile.svg',
                                fit: BoxFit.cover,
                              );
                            },
                          ) :
                          Opacity(
                            opacity: 0.37,
                            child: Image.network(
                                imgPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return SvgPicture.asset(
                                    'assets/widgets/default_user_profile.svg',
                                    fit: BoxFit.cover,
                                  );
                                },
                            ),
                          )
                      : SvgPicture.asset(
                          'assets/widgets/default_user_profile.svg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildWeightTag(List<BadgeInfoDto>? badges) {
    final weightBadge = badges!
        .firstWhere(
          (badge) => badge.badgeType == 'weight',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

    // badgeId가 비어있으면 뱃지를 표시하지 않음
    if (weightBadge.badgeId.isEmpty) { // != '' 대신 .isEmpty 사용
      return const SizedBox.shrink(); // 공간도 차지하지 않도록 SizedBox.shrink() 사용
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.2),
      child: SvgPicture.asset(
        'assets/widgets/${weightBadge.badgeId}.svg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink(); // 에러 시에도 공간 차지하지 않음
        },
      ),
    );
  }
}