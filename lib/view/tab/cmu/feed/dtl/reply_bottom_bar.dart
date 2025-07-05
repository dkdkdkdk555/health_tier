import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReplyBottomBar extends StatefulWidget {
  const ReplyBottomBar({
    super.key,
  });

  @override
  State<ReplyBottomBar> createState() => _ReplyBottomBarState();
}

class _ReplyBottomBarState extends State<ReplyBottomBar> {
  // TextField의 포커스 상태를 감지하기 위한 FocusNode
  final FocusNode _focusNode = FocusNode();
  // TextField의 내용을 제어할 컨트롤러
  final TextEditingController _textEditingController = TextEditingController();

  // 바의 현재 높이 (기본: 106, 확장 시: 116)
  double _barHeight = 106;
  // 전송 버튼의 가시성 (기본: false, 클릭 시: true)
  bool _showSendButton = false;

  // 텍스트 필드 테두리 색상
  Color _textFieldBorderColor = const Color(0xFFDDDDDD);
  // 전송 버튼 배경색
  Color _sendButtonColor = const Color(0xFFCCCCCC);


  @override
  void initState() {
    super.initState();
    // FocusNode에 리스너를 추가하여 포커스 변경 시 높이 및 버튼 가시성 변경
    _focusNode.addListener(_onFocusChange);
    // TextEditingController에도 리스너를 추가하여 텍스트 변경 감지
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
     _textEditingController.removeListener(_onTextChanged); // 리스너 해제
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      if (_focusNode.hasFocus) {
        // TextField에 포커스가 있을 때 높이 늘리고 버튼 표시
        _barHeight = 116;
        _showSendButton = true;
      } else {
        // TextField에서 포커스가 벗어났을 때 높이 줄이고 버튼 숨기기
        // (단, 입력된 텍스트가 없어야만 숨김)
        if (_textEditingController.text.isEmpty) {
          _barHeight = 106;
          _showSendButton = false;
        }
      } 
    });
  }

  void _onTextChanged() {
  // 텍스트가 비어있는지 여부에 따라 색상 업데이트
  _updateColorsBasedOnText(_textEditingController.text.isNotEmpty);
  }

  void _updateColorsBasedOnText(bool hasText) {
    setState(() {
      if (hasText) {
        _textFieldBorderColor = const Color(0xFF0D86E7); // 활성 색상
        _sendButtonColor = const Color(0xFF0D86E7); // 활성 색상
      } else {
        _textFieldBorderColor = const Color(0xFFDDDDDD); // 원래 색상
        _sendButtonColor = const Color(0xFFCCCCCC); // 원래 색상
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 높이를 가져와 하단 여백으로 사용
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer( // 높이 애니메이션을 위한 AnimatedContainer
      duration: const Duration(milliseconds: 250), // 애니메이션 지속 시간
      curve: Curves.easeOut, // 애니메이션 곡선
      height: _barHeight + keyboardHeight, // 키보드 높이만큼 바 높이 확장
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            width: 1,
            color: Color(0xFFEEEEEE),
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Stack( // 기존 Stack 구조를 유지하면서 버튼만 추가
        children: [
          Positioned(
            left: 20,
            top: 23,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                // 사용자 프로필 이미지
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/widgets/default_user_profile.svg',
                    fit: BoxFit.cover,
                  ),
                ),
                // 댓글 입력 필드
                Container(
                  width: 303, // 기존 너비 유지
                  height: 37,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: _textFieldBorderColor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextField(
                    focusNode: _focusNode, // FocusNode 연결
                    controller: _textEditingController, // TextEditingController 연결
                    decoration: const InputDecoration(
                      hintText: '댓글 달기',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 전송 버튼 (애니메이션 효과와 함께 나타나고 사라짐)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250), // 애니메이션 지속 시간
            curve: Curves.easeOut, // 애니메이션 곡선
            left: 294,
            top: _showSendButton ? 68 : _barHeight + keyboardHeight, // 가시성에 따라 위치 변경
            child: AnimatedOpacity( // 투명도 애니메이션
              opacity: _showSendButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer( // 버튼이 보이지 않을 때는 클릭 이벤트 무시
                ignoring: !_showSendButton,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: ShapeDecoration(
                    color: _sendButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: const Text(
                    '전송',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}