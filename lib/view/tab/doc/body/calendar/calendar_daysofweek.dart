import 'package:flutter/material.dart';

class CustomWeekdayRow extends StatelessWidget {
  final double heightRatio;
  final double widthRatio;
  const CustomWeekdayRow({
    super.key,
    required this.heightRatio,
    required this.widthRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.0 * widthRatio),
      child: Column(
        children: [
          SizedBox(
            height: 17 * heightRatio,
            child: SizedBox(
              width: 335 * widthRatio,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 38 * widthRatio,
                  children: [
                  for (int i = 0; i < 7; i++) ...[
                    SizedBox(
                      height: 17 * heightRatio,
                      width: 10 * widthRatio,
                      child: Text(
                        ['일', '월', '화', '수', '목', '금', '토'][i],
                        style: TextStyle(
                          fontSize: 11 * heightRatio,
                          fontFamily: 'Pretendard',
                          color: const Color.fromARGB(102, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 29 * heightRatio,),
        ],
      ),
    );
  }
}

