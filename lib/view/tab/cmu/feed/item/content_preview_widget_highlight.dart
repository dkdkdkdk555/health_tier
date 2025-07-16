import 'package:flutter/material.dart';

class ContentPreviewWidgetHighlight extends StatelessWidget {
  final String ctntPreview;
  final String searchKeyword;

  const ContentPreviewWidgetHighlight({
    super.key,
    required this.ctntPreview,
    this.searchKeyword = '', // 기본값 설정
  });

  // 텍스트를 검색어에 따라 하이라이팅하는 헬퍼 메서드 (TitleWidget과 동일)
  List<TextSpan> _buildHighlightedText(String text, String highlight) {
    if (highlight.isEmpty || text.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();

    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = lowerText.indexOf(lowerHighlight, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }

      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + highlight.length),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ));

      start = indexOfHighlight + highlight.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    const defaultStyle = TextStyle(
      color: Color(0xFF777777),
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      height: 1.40,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 1),
      child: SizedBox(
        height: 44, // 두 줄 텍스트의 높이
        child: RichText(
          text: TextSpan(
            style: defaultStyle, // 기본 스타일 적용
            children: _buildHighlightedText(ctntPreview, searchKeyword), // 하이라이팅 적용
          ),
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }
}