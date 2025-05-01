import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DocCalendarDiet extends StatefulWidget {
  const DocCalendarDiet({super.key});

  @override
  State<DocCalendarDiet> createState() => _DocCalendarDietState();
}

class _DocCalendarDietState extends State<DocCalendarDiet> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex:128,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: Column(
          children: [
            const Expanded(
              flex: 16,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '2025년 5월',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 33,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20)
              ),
            ),
            Container(
                width: 335,
                height: 1,
                decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            ),
            Expanded(
              flex: 36,
              child: Padding(padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    makeTotal('assets/icons/kcal.svg', '총 섭취 칼로리', '11,650 kcal'),
                    const Spacer(flex: 5,),
                    makeTotal('assets/icons/protein.svg', '총 섭취 단백질', '120g'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),

    );
  }

  Flexible makeTotal(String path, String text, String numunit) {
    return Flexible(
      flex: 6,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              path,
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                numunit,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}