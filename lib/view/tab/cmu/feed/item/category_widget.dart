import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.categoryNm,
  });

  final String categoryNm;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(bottom:4),
        decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
            ),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                        Text(
                            categoryNm,
                            style: const TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                            ),
                        ),
                    ],
                ),
            ],
        ),
    );
  }
}