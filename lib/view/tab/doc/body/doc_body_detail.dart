import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:my_app/main.dart' show bottomBarHandleKey, kcalTextKey, proteinTextKey, weightTextKey;
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
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 6 * htio,),
              Container(
                key: bottomBarHandleKey,
                width: 40 * wtio,
                height: 4 * htio,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE6E6E6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              SizedBox(height: 25 * htio,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left:65*wtio),
                    width: 306 * wtio,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        makeRow1(wtio, today, htio, detail),
                        SizedBox(height: 18 * htio,),
                        makeRow2(wtio, htio, detail, numberGroup),
                        SizedBox(height: 14 * htio,),
                        makeRow3(wtio, htio, detail, prvsWeight),
                        SizedBox(height: 18 * htio,),
                        makeRow4(wtio, htio, detail),
                      ],
                    ),
                  ),
                ],
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

  Widget makeRow4(double wtio, double htio, DocDayDetail? detail) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 128 * htio
      ),
      child: Container(
        margin: EdgeInsets.only(right: 65 * wtio),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '메모',
              style: TextStyle(
                color: const Color(0xFFAAAAAA),
                fontSize: 12 * htio,
                fontFamily: 'Pretendard',
              ),
            ),
            SizedBox(width: 8 * wtio),
            Expanded(
              child:Text(
                detail?.memo ?? '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12 * htio,
                  fontFamily: 'Pretendard',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget makeRow3(double wtio, double htio, DocDayDetail? detail, double? prvsWeight) {
    final diffWeight = (detail?.weight != null && prvsWeight != null) ? detail!.weight! - prvsWeight : null;
    final isNegative = diffWeight != null && diffWeight < 0;
    final isNull = diffWeight == null;
    // 아이콘 결정
    final iconPath = isNull ? 'assets/icons/neutral.svg' : (isNegative ? 'assets/icons/down.svg' : 'assets/icons/up.svg');
    // 텍스트 색상 결정
    final textColor = isNull ? null : ( isNegative ? const Color(0xFF0D85E7) : const Color(0xFFF04C4C) );
    // 텍스트 값 (부호 제외)
    final textValue = isNull ? '' : '${diffWeight.abs().toStringAsFixed(1)}kg';
    
    final muscleValue = detail?.muscle;
    String muscleText = '';
     if (muscleValue != null) {
      // 소수점 첫째 자리가 0이면 정수만 표시
      if (muscleValue % 1 == 0) {
        muscleText = muscleValue.toInt().toString();
      } else {
        // 소수점은 최대 1자리까지 표시
        muscleText = NumberFormat("#.#").format(muscleValue);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 12 * htio,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '전일 대비',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12 * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.12 * htio,
                ),
              ),
              SizedBox(width: 4 * wtio),
              Container(
                width: 12 * wtio,
                height: 12 * htio,
                clipBehavior: Clip.none,
                decoration: const BoxDecoration(),
                child: SvgPicture.asset(iconPath),
              ),
              SizedBox(width: 2 * wtio),
              Text(
                textValue,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12 * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.12 * htio,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * wtio),
        SizedBox(
          height: 8 * htio,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                key: kcalTextKey,
                'kcal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 12 * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.12 * htio,
                ),
              ),
              SizedBox(width: 4 * wtio),
              Text(
                detail?.totalCalorie != null ? '${detail?.totalCalorie!.toInt()}' : '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12 * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.12 * htio,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * wtio),
        SizedBox(
          height: 9 * htio,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '골격근',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 12 * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.12 * htio,
                ),
              ),
              SizedBox(width: 4 * wtio),
              Text(
                muscleText=='' ? '' : '${muscleText}kg',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12 * wtio,
                  fontFamily: 'Pretendard',
                  height: 0.12 * htio,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget makeRow2(double wtio, double htio, DocDayDetail? detail, AutoSizeGroup numberGroup) {
    final proteinValue = detail?.totalProtein;
    String proteinText;
    final weightValue = detail?.weight;
    String weightText;

    if (proteinValue != null) {
      // 소수점 첫째 자리가 0이면 정수만 표시
      if (proteinValue % 1 == 0 || proteinValue >= 1000) {
        proteinText = proteinValue.toInt().toString();
      } else {
        // 소수점은 최대 1자리까지 표시
        proteinText = NumberFormat("#.#").format(proteinValue);
      }
    } else {
      proteinText = '단백질';
    }

    if (weightValue != null) {
      // 소수점 첫째 자리가 0이면 정수만 표시
      if (weightValue % 1 == 0) {
        weightText = weightValue.toInt().toString();
      } else {
        // 소수점은 최대 1자리까지 표시
        weightText = NumberFormat("#.#").format(weightValue);
      }
    } else {
      weightText = '몸무게';
    }

   
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 30 * htio,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                weightText,
                key: weightTextKey,
                style: TextStyle(
                  color: detail?.weight != null ? Colors.black : Colors.black.withAlpha(30),
                  fontSize: (detail?.weight != null ? 42: 32) * htio,
                  fontFamily: 'Pretendard',
                  height: 0.04 * htio,
                  letterSpacing: -1.0 * wtio, 
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(width: 4 * htio),
              SizedBox(
                child: Text(
                  'kg',
                  style: TextStyle(
                    color: const Color(0xFF999999),
                    fontSize: 32 * htio,
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                proteinText,
                key: proteinTextKey,
                maxLines: detail?.totalProtein != null ? 1 : 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: detail?.totalProtein != null ? Colors.black : Colors.black.withAlpha(30),
                  fontSize: (detail?.totalProtein != null ? ((proteinValue! >= 1000) ? 38 : 42): 32) * htio,
                  fontFamily: 'Pretendard',
                  height: 0.04 * htio,
                  letterSpacing: -1.0 * wtio, 
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(width: 3 * htio),
              Text(
                'g',
                style: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 32 *  htio,
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
        mainAxisAlignment: MainAxisAlignment.start,
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
              SizedBox(width: 4 * wtio),
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
              SizedBox(width: 4 * wtio),
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