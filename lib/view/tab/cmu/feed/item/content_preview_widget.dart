import 'package:flutter/material.dart';

class ContentPreviewWidget extends StatelessWidget {
  final String ctntPreview;
  const ContentPreviewWidget({super.key, required this.ctntPreview});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 1),
      child: SizedBox(
        height: 44, // 두 줄 텍스트의 높이
        child: Text(
          ctntPreview,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // 2줄로 제한
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 14,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.40,
          ),
        ),
      ),
    );
  }
}