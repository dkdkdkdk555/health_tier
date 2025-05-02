import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/util/responsive_scrollable_textbox.dart';

class DocDietDetail extends StatelessWidget {
  DocDietDetail({
    super.key,
    required this.focusedDay,
    required this.bottomHeight,
  });
  final DateTime focusedDay;
  final double bottomHeight;

  late double heightRatio;
  late double widthRatio;

  @override
  Widget build(BuildContext context) {
    heightRatio = ScreenRatio(context).heightRatio;
    widthRatio = ScreenRatio(context).widthRatio;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(47)),
            border: Border(
              left: BorderSide(width: 2 * widthRatio ,color: const Color(0xFFEEEEEE)),
              top: BorderSide(width: 2 * widthRatio, color: const Color(0xFFEEEEEE)),
              right: BorderSide(width: 2 * widthRatio, color: const Color(0xFFEEEEEE)),
              bottom: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
          ),
          child: Column(
            children: [
              const Spacer(flex:4),
              Expanded(
                flex:2,
                child: Container(
                  width: 40 * widthRatio,
                  height: 4 * heightRatio,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                )
              ),
              Expanded(
                flex: 201,
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    Expanded(
                      flex: 65,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * widthRatio,),
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16 * heightRatio),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 44,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: AutoSizeText(
                                        '1 끼니', // 9글자 제한
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: const Color(0xFFAAAAAA),
                                          fontSize: 16 * heightRatio,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(
                                    flex: 8,
                                  ),
                                  const Expanded(
                                    flex: 200,
                                    child: ScrollableTextBox(
                                      text: '닭 가슴살, 현미밥',
                                      lineFontSize: 16,
                                      boxFontSize: 13,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const Spacer(
                                    flex: 8,
                                  ),
                                  Expanded(
                                    flex: 75,
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: AutoSizeText(
                                            '2,650 kcal',
                                            maxLines: 1,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: const Color(0xFF333333),
                                              fontSize: 12 * heightRatio,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: AutoSizeText(
                                            '50 g',
                                            maxLines: 1,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: const Color(0xFF333333),
                                              fontSize: 12 * heightRatio,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        )
                                     ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Container(
                              width: 335 * widthRatio,
                              height: 1,
                              decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
              SizedBox(
                height: bottomHeight,
              )
            ],
          ),
        ),
      ]
    );
  }
}