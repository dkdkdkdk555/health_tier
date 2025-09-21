import 'package:flutter/material.dart';

class ErrorContentWidget extends StatelessWidget {
  final String mainText;
  final bool isExistTopLine;
  final bool isExistBottomLine;
  final double horizontal;
  final double vertical;
  final bool isIconView;
  const ErrorContentWidget({
    super.key,
    this.mainText = '데이터 로딩 중 오류가 발생했습니다.',
    this.isExistTopLine = false,
    this.isExistBottomLine = false,
    this.horizontal = 10,
    this.vertical = 10,
    this.isIconView = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          isExistTopLine ? Container(
            height: 2.5,
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
          ) : const SizedBox.shrink(),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
              child: Column(
                children: [
                  isIconView ? Icon(
                    Icons.error,
                    color: Colors.amber.shade200,
                  ) : const SizedBox.shrink(),
                  Text(
                    mainText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ),
          isExistBottomLine ? Container(
            height: 2.5,
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
