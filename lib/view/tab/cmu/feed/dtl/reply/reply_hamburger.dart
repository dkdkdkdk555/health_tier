import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ReplyHamburgerAction 열거형 정의: 메뉴 아이템의 액션을 구분하기 위함
enum ReplyHamburgerAction {
  edit,
  delete,
  report,
}

class ReplyHamburger extends PopupMenuEntry<ReplyHamburgerAction> {
  final int writerUserId;
  final int loginUserId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const ReplyHamburger({
    super.key,
    required this.writerUserId,
    required this.loginUserId,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  @override
  double get height => 0; // PopupMenuEntry가 차지하는 높이는 0으로 설정하여 내부 위젯이 높이를 결정하도록 함

  @override
  bool represents(ReplyHamburgerAction? value) {
    // 이 메뉴 항목이 특정 값을 나타내는지 여부
    // 여기서는 모든 액션을 포함할 수 있으므로 항상 true를 반환해도 무방합니다.
    return true;
  }

  @override
  ReplyHamburgerState createState() => ReplyHamburgerState();
}

class ReplyHamburgerState extends State<ReplyHamburger> {
  @override
  Widget build(BuildContext context) {
    // 팝업 메뉴의 배경과 그림자 등을 위한 컨테이너 (디자인 그대로 유지)
    return Container(
      width: 103, // 고정된 너비
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내부 콘텐츠에 맞게 높이 조절
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.writerUserId == widget.loginUserId) ...[
            // 작성자와 로그인 유저가 같은 경우: 수정
            _buildMenuItem(
              iconAsset: 'assets/icons/reply/update_feed.svg',
              text: '수정',
              onTap: () {
                Navigator.pop(context, ReplyHamburgerAction.edit); // 메뉴 닫고 액션 반환
                widget.onEdit();
              },
            ),
            Container(
              width: double.infinity,
              height: 1,
              decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            ),
            // 작성자와 로그인 유저가 같은 경우: 삭제
            _buildMenuItem(
              iconAsset: 'assets/icons/reply/delete_feed.svg',
              text: '삭제',
              onTap: () {
                Navigator.pop(context, ReplyHamburgerAction.delete); // 메뉴 닫고 액션 반환
                widget.onDelete();
              },
            ),
          ] else ...[
            // 작성자와 로그인 유저가 다른 경우: 신고
            _buildMenuItem(
              iconAsset: 'assets/icons/reply/delete_feed.svg', // 신고 아이콘 필요
              text: '신고',
              onTap: () {
                Navigator.pop(context, ReplyHamburgerAction.report); // 메뉴 닫고 액션 반환
                widget.onReport();
              },
            ),
          ],
        ],
      ),
    );
  }

  // 메뉴 아이템 위젯 헬퍼 함수
  Widget _buildMenuItem({
    required String iconAsset,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell( // 탭 가능한 영역을 제공하기 위해 InkWell 사용
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // 클릭 영역 확보
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: text == '수정' ? 2.41 : 3.25, // 아이콘별 미세 조정 (기존 코드 반영)
                left: text == '수정' ? 1.68 : 3.75,
                right: text == '수정' ? 2.29 : 3.75,
                bottom: text == '수정' ? 0.97 : 2.95,
              ),
              child: SizedBox(
                width: 16,
                height: 16,
                child: SvgPicture.asset(
                  iconAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Pretendard',
                height: 1.2, // Text의 height를 적절히 조절 (0.11은 너무 작아서 텍스트가 안보일 수 있음)
              ),
            ),
          ],
        ),
      ),
    );
  }
}