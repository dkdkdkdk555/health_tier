import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/model/diet/doc_diet_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/responsive_scrollable_textbox.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/util/up_arrow.dart';
import 'package:my_app/view/common/error_widget.dart';

class DocDietDetail extends ConsumerWidget {
  const DocDietDetail({
    super.key,
    required this.focusedDay,
    required this.bottomHeight,
  });

  final DateTime focusedDay;
  final double bottomHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    final dietListAsync = ref.watch(
      selectDietDocList(DateFormat('yyyy-MM-dd').format(focusedDay)),
    );

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(47)),
            border: Border(
              left: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
              top: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
              right: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
              bottom: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 8 * htio), // spacer 대체
              Container(
                width: 40 * wtio,
                height: 4 * htio,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE6E6E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              SizedBox(height: 52 * htio), // spacer 대체
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
                  child: dietListAsync.when(
                    data: (dietList) {
                      if (dietList.isEmpty) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const UpArrowIndicator(),
                              SizedBox(height: 8 * htio),
                              Text(
                                '위로 끌어올려서\n식단을 입력하세요',
                                style: TextStyle(
                                  fontSize: 21 * htio,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return makeDietList(dietListAsync, htio, wtio);
                      }
                    },
                    loading: () => const Center(child: AppLoadingIndicator()),
                    error: (e, st) => const ErrorContentWidget(
                      horizontal: 20,
                      vertical: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget makeDietList(
    AsyncValue<List<DayDietModel>> dietListAsync,
    double heightRatio,
    double widthRatio,
  ) {
    return dietListAsync.when(
      data: (dietList) {
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: dietList.length,
          itemBuilder: (context, index) {
            final diet = dietList[index];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16 * heightRatio),
              child: Row(
                children: [
                  SizedBox(
                    width: 80 * widthRatio,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        diet.title ?? '',
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
                  SizedBox(width: 12 * widthRatio),
                  Expanded(
                    child: ScrollableTextBox(
                      text: diet.diet ?? '',
                      lineFontSize: 16 * heightRatio,
                      boxFontSize: 13 * heightRatio,
                      lineStand: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 12 * widthRatio),
                  SizedBox(
                    width: 90 * widthRatio,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          diet.calorie != null ? '${diet.formattedCalorie} kcal' : '-',
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 12 * widthRatio,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          diet.protein != null ? '${diet.formattedProtein}g' : '-',
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 12 * widthRatio,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => Container(
            width: 335 * widthRatio,
            height: 1 * heightRatio,
            color: const Color(0xFFEEEEEE),
          ),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (e, st) =>
          const ErrorContentWidget(mainText: '', horizontal: 20, vertical: 25),
    );
  }
}
