import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final String categoryNm;
  final double htio;
  final double wtio;
  const CategoryWidget({
    super.key,
    required this.categoryNm,
    required this.htio,
    required this.wtio,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * wtio, vertical: 4 * htio),
        margin: EdgeInsets.only(bottom:4 * htio),
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
            spacing: 10 * wtio,
            children: [
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4 * wtio,
                    children: [
                        Text(
                            categoryNm,
                            style: TextStyle(
                                color: const Color(0xFF777777),
                                fontSize: 12 * htio,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.50 * htio,
                            ),
                        ),
                    ],
                ),
            ],
        ),
    );
  }
}