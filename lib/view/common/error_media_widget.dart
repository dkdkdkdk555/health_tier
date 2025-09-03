import 'package:flutter/material.dart';

class ErrorMediaWidget extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  const ErrorMediaWidget({
    super.key,
    required this.width,
    required this.height,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, 
      height: height,
      margin: const EdgeInsets.only(top: 20),
      color: Colors.grey[200], // 배경색
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline, // 에러 아이콘
            color: Colors.red.shade200,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: Colors.red.shade200, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}