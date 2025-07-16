import 'package:flutter/material.dart';

class TitleWidgetHighlight extends StatelessWidget {
  final String title;
  final String categoryNm;
  final String searchKeyword; // ✅ 새로운 파라미터

  const TitleWidgetHighlight({
    super.key,
    required this.title,
    required this.categoryNm,
    this.searchKeyword = '', // 기본값 설정
  });

  // 텍스트를 검색어에 따라 하이라이팅하는 헬퍼 메서드
  List<TextSpan> _buildHighlightedText(String text, String highlight) {
    if (highlight.isEmpty || text.isEmpty) {
      return [TextSpan(text: text)]; // 하이라이트할 단어가 없거나 텍스트가 비어있으면 일반 텍스트 반환
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase(); // 대소문자 구분 없이 검색
    final lowerHighlight = highlight.toLowerCase();

    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = lowerText.indexOf(lowerHighlight, start)) != -1) {
      // 하이라이트될 부분 이전의 텍스트 추가
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }

      // 하이라이트될 텍스트 부분 추가 (굵게)
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + highlight.length),
        style: const TextStyle(fontWeight: FontWeight.bold), // ✅ 굵게 표시
      ));

      start = indexOfHighlight + highlight.length;
    }

    // 마지막 하이라이트 이후 남은 텍스트 추가
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    const defaultStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      height: 1.40,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 44, // 두 줄 텍스트의 최대 높이 (대략 16px * 1.4 * 2줄)
      ),
      child: RichText( // ✅ RichText 사용
        text: TextSpan(
          style: defaultStyle, // 기본 스타일 적용
          children: _buildHighlightedText(title, searchKeyword), // 하이라이팅 적용
        ),
        textAlign: TextAlign.left,
        maxLines: 1, // ✅ RichText에도 maxLines 적용
        overflow: TextOverflow.ellipsis, // ✅ RichText에도 overflow 적용
      ),
    );
  }
}