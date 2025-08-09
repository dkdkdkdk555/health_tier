import 'package:flutter/material.dart';

/// TextField 내에서 @으로 시작하는 단어를 특정 색상으로 스타일링하는 컨트롤러
class StyledTextController extends TextEditingController {
  StyledTextController({super.text});

  // @으로 시작하는 단어에 적용할 색상
  final Color _highlightColor = const Color(0xFF0D86E7);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    // 기본 스타일 (TextField에 설정된 style을 따름)
    final defaultStyle = style ?? const TextStyle(
      color: Color(0xFF000000),
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      height: 1.50,
    );

    final List<TextSpan> spans = [];
    // @으로 시작하는 단어 (공백이 아닌 문자가 이어지는)를 찾는 정규식
    // 예: @hello, @world123
    final RegExp regex = RegExp(r'(\S*@\S+)');

    // 텍스트를 정규식 매칭 부분과 비매칭 부분으로 분리하여 순회
    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        // 매칭된 부분 (예: @닉네임)에 하이라이트 스타일 적용
        spans.add(
          TextSpan(
            text: match.group(0), // 정규식에 매칭된 전체 문자열
            style: defaultStyle.copyWith(color: _highlightColor), // 기본 스타일을 복사하여 색상만 변경
          ),
        );
        return ''; // 이미 TextSpan으로 추가했으므로 빈 문자열 반환
      },
      onNonMatch: (String nonMatch) {
        // 매칭되지 않은 일반 텍스트에 기본 스타일 적용
        spans.add(
          TextSpan(
            text: nonMatch,
            style: defaultStyle,
          ),
        );
        return ''; // 이미 TextSpan으로 추가했으므로 빈 문자열 반환
      },
    );

    // 모든 TextSpan을 포함하는 최종 TextSpan 반환
    return TextSpan(style: defaultStyle, children: spans);
  }
}
