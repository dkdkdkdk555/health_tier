import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_app/model/body/doc_detail_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/screen_ratio.dart';

class DocBodyDetail extends ConsumerWidget {
  const DocBodyDetail({
    super.key,
    required this.focusedDay,
    required this.bottomHeight,
  });

  final DateTime focusedDay;
  final double bottomHeight;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = ScreenRatio(context);
    final htio = ratio.heightRatio;
    final wtio = ratio.widthRatio;
    final searchDay = DateFormat('yyyy-MM-dd').format(focusedDay);
    final docDtl = ref.watch(htDayDocDetail(searchDay));
    final detail = docDtl.asData?.value;
    final prvsWeight = detail?.id != null ? ref.watch(getPreviousWeight(searchDay)).value : null;
    final today = DateFormat('yyyy.MM.dd (E)', 'ko').format(focusedDay);

    final numberGroup = AutoSizeGroup();

    return Stack(
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
              SizedBox(height: 8 * htio,),
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
              SizedBox(height: 28 * htio,),
              SizedBox(
                height:256 * htio,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 244 * wtio,
                      child: Column(
                        children: [
                          makeRow1(wtio, today, htio, detail),
                          SizedBox(height: 18 * htio,),
                          makeRow2(wtio, htio, detail, numberGroup),
                          SizedBox(height: 8 * htio,),
                          makeRow3(detail, prvsWeight),
                          SizedBox(height: 18 * htio,),
                          makeRow4(detail),
                        ],
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
        // 도장(하루평가)
        if (detail?.stamp != null && detail?.stamp != '')
        Positioned(
          top: 57 * htio,
          right: 0 * wtio,
          child: SizedBox(
            width: 130 * wtio,
            height: 130 * htio,
            child: Transform.rotate(
              angle: -0.52,
              child: SvgPicture.asset(
                'assets/icons/stamp_${detail!.stamp.toString()}.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ]
    );
  }

  Expanded makeRow4(DocDayDetail? detail) {
    return Expanded(
      flex: 66,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: AutoSizeText(
              '메모',
              style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 12,
                  fontFamily: 'Pretendard',
              ),
            ),
          ),
          Expanded(
              child: AutoSizeText(
                  detail?.memo ?? '',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                  ),
              ),
          )
        ],
      ),
    );
  }

  Flexible makeRow3(DocDayDetail? detail, double? prvsWeight) {
    final diffWeight = (detail?.weight != null && prvsWeight != null) ? detail!.weight! - prvsWeight : null;
    final isNegative = diffWeight != null && diffWeight < 0;
    final isNull = diffWeight == null;
    // 아이콘 결정
    final iconPath = isNull ? 'assets/icons/neutral.svg' : (isNegative ? 'assets/icons/down.svg' : 'assets/icons/up.svg');
    // 텍스트 색상 결정
    final textColor = isNull ? null : ( isNegative ? const Color(0xFF0D85E7) : const Color(0xFFF04C4C) );
    // 텍스트 값 (부호 제외)
    final textValue = isNull ? '' : '${diffWeight.abs().toStringAsFixed(1)}kg';

    return Flexible(
      flex: 6,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final fontSize = availableHeight * 0.55; // 단위용
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: AutoSizeText(
                  '이전 대비',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize,
                      fontFamily: 'Pretendard',
                      height: 0.12,
                  ),
                ),
              ),
              SizedBox(
                width: fontSize,
                height: fontSize,
                child: SvgPicture.asset(iconPath),
              ),
              AutoSizeText(
                textValue,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontFamily: 'Pretendard',
                    height: 0.12,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: AutoSizeText(
                  'kcal',
                  style: TextStyle(
                      color: const Color(0xFFAAAAAA),
                      fontSize: fontSize,
                      fontFamily: 'Pretendard',
                      height: 0.12,
                  ),
                ),
              ),
              AutoSizeText(
                detail?.totalCalorie != null ? '${detail?.totalCalorie!.toInt()}' : '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontFamily: 'Pretendard',
                    height: 0.12,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: AutoSizeText(
                  'BMI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color(0xFFAAAAAA),
                      fontSize: fontSize,
                      fontFamily: 'Pretendard',
                      height: 0.12,
                  ),
                ),
              ),
              AutoSizeText(
                //TODO: 동적으로 만들기
                '23.5',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontFamily: 'Pretendard',
                    height: 0.12,
                ),
              )
            ],
          );
        }
      )
    );
  }

  Widget makeRow2(double wtio, double htio, DocDayDetail? detail, AutoSizeGroup numberGroup) {
   
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 30 * htio,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                detail?.weight != null ? '${detail?.weight}' : '몸무게',
                style: TextStyle(
                  color: detail?.weight != null ? Colors.black : Colors.black.withAlpha(30),
                  fontSize: (detail?.weight != null ? 42: 32) * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.04 * htio,
                  letterSpacing: -1.0 * wtio, 
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(width: 4 * wtio),
              SizedBox(
                child: Text(
                  'kg',
                  style: TextStyle(
                    color: const Color(0xFF999999),
                    fontSize: 32 * wtio,
                    fontFamily: 'Pretendard',
                    height: 0.05 * htio,
                    letterSpacing: -1.0 * wtio, 
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width:14 * wtio),
        SizedBox(
          height: 30 * htio,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                detail?.totalProtein != null ? '${detail?.totalProtein}' : '단백질',
                maxLines: detail?.totalProtein != null ? 1 : 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: detail?.totalProtein != null ? Colors.black : Colors.black.withAlpha(30),
                  fontSize: (detail?.totalProtein != null ? 42: (detail?.weight == null ? 32: 26)) * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.04 * htio,
                  letterSpacing: -1.0 * wtio, 
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(width: 4 * wtio),
              Text(
                'g',
                style: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 32 *  wtio,
                  letterSpacing: -1.0 * wtio, 
                  fontFamily: 'Pretendard',
                  height: 0.05 * htio,
                  fontWeight: FontWeight.w400
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget makeRow1(double wtio, String today, double htio, DocDayDetail? detail) {
    return SizedBox(
      height: 18 * htio,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 날짜
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                today,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12 * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.12 * htio,
                ),
              ),
            ],
          ),
          // 구분선
          boundary(wtio, htio),
          // 운동 여부
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              textYN(wtio, htio, text: '운동여부', yn:detail?.workYn),
              const SizedBox(width: 4),
              iconYN(1.0, 1.0, 'assets/icons/work_out.svg', detail?.workYn), // yn = 1이면 활성
            ],
          ),
          // 구분선
          boundary(wtio, htio),
          // 음주 여부
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              textYN(wtio, htio, text: '음주여부', yn:detail?.drunYn),
              const SizedBox(width: 4),
              iconYN(1.0, 1.0, 'assets/icons/drink.svg', detail?.drunYn), // yn = 0이면 비활성
            ],
          ),
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

  Widget textYN(double wtio, double htio, {required String text, required int? yn}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: TextStyle(
        fontSize: 12 * wtio,
        color: yn == 1
            ? const Color(0xFF333333)
            : Colors.black.withAlpha(77),
        fontFamily: 'Pretendard',
        height: 0.12 * htio,
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