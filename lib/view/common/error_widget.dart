import 'package:flutter/material.dart';

class ErrorContentWidget extends StatelessWidget {
  final String mainText;
  final bool isExistTopLine;
  final double horizontal;
  final double vertical;
  const ErrorContentWidget({
    super.key,
    required this.mainText,
    this.isExistTopLine = false,
    required this.horizontal,
    required this.vertical
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                Icon(
                  Icons.error,
                  color: Colors.amber.shade200,
                ),
                Text(
                  mainText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}