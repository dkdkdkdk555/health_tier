import 'package:flutter/material.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class ScrollableTextBox extends StatelessWidget {
  final String text;
  final double boxFontSize; // ScrollView로 변할때 fontSize
  final double lineFontSize; // 일반 Text일때 fontsize
  final FontWeight fontWeight;
  final int lineStand; // 몇줄부터 Scrollbox로 전환할건지 기준

  const ScrollableTextBox({
    super.key,
    required this.text,
    required this.boxFontSize,
    required this.lineFontSize,
    this.lineStand = 2,
    this.fontWeight = FontWeight.normal
  });

  @override
  Widget build(BuildContext context) {
    final heightRatio = ScreenRatio(context).heightRatio;
    // 줄 수 측정
    final span = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: lineFontSize * heightRatio,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
      ),
    );

    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    // Layout을 위해 실제로 그림
    tp.layout(
      maxWidth: MediaQuery.of(context).size.width,
    );

    final lineCount = tp.computeLineMetrics().length;

    if (lineCount <= lineStand) {
      // 그냥 출력
      return Text(
        text,
        style: span.style,
      );
    } else {
      // 테두리 박스 + 스크롤
      return Container(
        height: lineFontSize * heightRatio * 7, // 3줄 높이만큼 제한
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Text(
            text,
            style: TextStyle(
              fontSize: boxFontSize * heightRatio,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
  }
}
