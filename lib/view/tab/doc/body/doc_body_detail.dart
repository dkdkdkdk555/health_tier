import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/model/doc_detail_model.dart';
import 'package:my_app/providers/db_providers.dart';

class DocBodyDetail extends ConsumerWidget {
  const DocBodyDetail({
    super.key,
    required this.focusedDay,
  });

  final DateTime focusedDay;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    final searchDay = DateFormat('yyyy-MM-dd').format(focusedDay);
    final docDtl = ref.watch(htDayDocDetail(searchDay));

    final detail = docDtl.asData?.value;
    final today = DateFormat('yyyy.MM.dd (E)', 'ko').format(focusedDay);

    final numberGroup = AutoSizeGroup();

    return Expanded(
      flex: 148,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(47)),
              border: Border(
                left: BorderSide(width: 2 * wtio ,color: const Color(0xFFEEEEEE)),
                top: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
                right: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
                bottom: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
            child: Column(
              children: [
                const Spacer(flex:2),
                Expanded(
                  flex:1,
                  child: Container(
                    width: 40 * wtio,
                    height: 4 * htio,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE6E6E6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  )
                ),
                const Spacer(flex:7),
                Flexible(
                  flex:41,
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 9),
                    child: Row(
                      children: [
                        const SizedBox(width: 66),
                        Flexible(
                          child: Column(
                            children: [
                              makeRow1(wtio, today, htio, detail),
                              const Spacer(flex:9),
                              makeRow2(detail, numberGroup),
                              const Spacer(flex:4),
                              Flexible(
                                flex: 6,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Row(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Text(
                                            '이전 대비',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Pretendard',
                                                height: 0.12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: SvgPicture.asset(
                                            'assets/icons/down.svg'
                                          ),
                                        ),
                                        const Text(
                                          '1.12kg',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Color(0xFF0D85E7),
                                              fontSize: 14,
                                              fontFamily: 'Pretendard',
                                              height: 0.12,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Text(
                                            'kcal',
                                            style: TextStyle(
                                                color: Color(0xFFAAAAAA),
                                                fontSize: 14,
                                                fontFamily: 'Pretendard',
                                                height: 0.12,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          '11,650',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'Pretendard',
                                              height: 0.12,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Text(
                                            'BMI',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xFFAAAAAA),
                                                fontSize: 14,
                                                fontFamily: 'Pretendard',
                                                height: 0.12,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          '23.5',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'Pretendard',
                                              height: 0.12,
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                )
                              ),
                              const Spacer(flex:9),
                              const Expanded(
                                flex: 27,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Text(
                                        '메모',
                                        style: TextStyle(
                                            color: Color(0xFFAAAAAA),
                                            fontSize: 14,
                                            fontFamily: 'Pretendard',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: 260,
                                        child: Text(
                                            '단백질 섭취량을 늘려야겠다. 단백질 섭취량을 늘려야겠다. 단백질 섭취량을 늘려야겠다. 단백질 섭취량을 늘려야겠다. 단백질 섭취량을 늘려야겠다.  단백질 섭취량을 늘려야겠다. 단백질 섭취량을 늘려야겠다.',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Pretendard',
                                            ),
                                        ),
                                    )
                                  ],
                                ),
                              ),
                            
                            ],
                          ),
                        ),
                        const SizedBox(width: 66),
                      ],
                    ),
                  )
                ),
                const Spacer(flex:23,),
              ],
            ),
          ),
          // 도장(하루평가)
          Positioned(
            top: 24 * htio,
            right: 16 * wtio,
            child: SizedBox(
              width: 100 * wtio,
              height: 100 * htio,
              child: SvgPicture.asset(
                'assets/icons/stamp_perfect.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ]
      )
    );
  }

  Flexible makeRow2(DocDayDetail? detail, AutoSizeGroup numberGroup) {
    return Flexible(
      flex: 18,
      fit: FlexFit.loose,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final fontSizeBig = availableHeight * 1.13; // 숫자용
          final fontSizeSmall = availableHeight * 0.75; // 단위용
          return Row(
            // mainAxisSize: MainAxisSize.min, // 내용 크기만큼만 차지
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 78,
                fit: FlexFit.loose,
                child: AutoSizeText(
                  detail?.weight != null ? '${detail?.weight}' : '몸무게',
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  group: numberGroup,
                  style: TextStyle(
                    fontSize: fontSizeBig,
                    color: detail?.weight != null ? Colors.black : Colors.black.withAlpha(30),
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.bold,
                    height: 0.9
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Flexible(
                flex: 35,
                fit: FlexFit.loose,
                child: Text(
                  "kg",
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: const Color(0xFF999999),
                    fontFamily: 'Pretendard',
                    height: 1.6
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Flexible(
                flex: 74,
                fit: FlexFit.loose,
                child: AutoSizeText(
                  detail?.totalProtein != null ? '${detail?.totalProtein}' : '단백질\n섭취량',
                  maxLines: detail?.totalProtein != null ? 1 : 2,
                  overflow: TextOverflow.visible,
                  group: detail?.totalProtein != null ? numberGroup : null,
                  style: TextStyle(
                    fontSize: fontSizeBig,
                    color: detail?.totalProtein != null ? Colors.black : Colors.black.withAlpha(30),
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.bold,
                    height: 0.9
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Flexible(
                flex: 19,
                fit: FlexFit.loose,
                child: Text(
                  "g",
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: const Color(0xFF999999),
                    fontFamily: 'Pretendard',
                    height: 1.6
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Expanded makeRow1(double wtio, String today, double htio, DocDayDetail? detail) {
    return Expanded(
      flex: 9,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Flexible(
            flex: 87,
            child: AutoSizeText(
              today,
              maxLines: 1,
              minFontSize: 9,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          boundary(wtio, htio),
          textYN(wtio, text:"운동 여부", yn:detail?.workYn),
          const Spacer(flex:4),
          iconYN(wtio, htio, 'assets/icons/work_out.svg', detail?.workYn),
          boundary(wtio, htio),
          textYN(wtio, text:"음주 여부", yn:detail?.drunYn),
          const Spacer(flex:4),
          iconYN(wtio, htio, 'assets/icons/drink.svg', detail?.drunYn),
        ],
      ),
    );
  }

  Widget iconYN(double wtio, double htio, String path, int? yn) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 16 * wtio,
        height: 16 * htio,
        child: SvgPicture.asset(
          path,
          colorFilter: ColorFilter.mode(
            yn == 1
                ? const Color(0xFF333333)
                : Colors.black.withAlpha(77),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  } 

  Flexible textYN(double wtio, {required String text, required int? yn}) {
    return Flexible(
      flex: 45,
      child: AutoSizeText(
        text,
        maxLines: 1,
        minFontSize: 10,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          color: yn == 1
              ? const Color(0xFF333333)
              : Colors.black.withAlpha(77),
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }

  Container boundary(double wtio, double htio) {
    return Container(
      width: 1 * wtio,
      height: 8 * htio,
      margin: EdgeInsets.symmetric(horizontal: 6 * wtio),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.10000000149011612),
      ),
    );
  }
}