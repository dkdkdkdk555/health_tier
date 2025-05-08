import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app/model/stc/day_range_param.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/date_picker.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/stc/stc_app_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class StcMain extends ConsumerStatefulWidget {
  const StcMain({super.key});

  @override
  ConsumerState<StcMain> createState() => _StcMainState();
}

var htio = 0.0;
var wtio = 0.0;

class _StcMainState extends ConsumerState<StcMain> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedStcTabIndex; // 캐시된 값 불러오기
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedStcTabIndex = index; // 캐시된 값 불러오기
    });
  }

  int? focusedIndex; // weights 데이터 순번
  bool showTooltip = false; //말풍선 보여주는지 여부

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  List<bool> whichButtonPush = [true, false, false, false]; // 기간조회버튼 4가지의 

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    final param = DayRange(
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate),
    );

    final stcList = ref.watch(selectWeightList(param));

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (!sizingInformation.isMobile) return const Scaffold();

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              StcAppBar(selectedIndex: _selectedIndex, onTap: _onTap),
              Expanded(
                flex: 329,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      periodSearchForm(context),
                      Expanded(
                        flex: 305,
                        child: Column(
                          children: [
                            const Spacer(flex: 34),
                            Expanded(
                              flex: 124,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final chartHeight = constraints.maxHeight;
                                  final chartWidth = constraints.maxWidth;

                                  return stcList.when(
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (err, stack) => Center(child: Text('에러 발생: $err')),
                                    data: (list) {
                                      if (list.isEmpty) {
                                        return const Center(child: Text('데이터가 없습니다'));
                                      }

                                      final values = list.map((e) => e.weight).toList();
                                      final days = list.map((e) => e.day).toList();

                                      const decVal = 0.4;
                                      final rawMin = values.reduce((a, b) => a < b ? a : b);
                                      final rawMax = values.reduce((a, b) => a > b ? a : b);
                                      final minY = rawMin - decVal;
                                      final maxY = rawMax + decVal;

                                      const lineCount = 5;
                                      final interval = (maxY - minY) / (lineCount - 1);
                                      final yDoubles = List.generate(
                                        lineCount,
                                        (i) => double.parse((minY + interval * i).toStringAsFixed(1)),
                                      );

                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ...yDoubles.map((y) {
                                            final relativeY = (maxY - y) / (maxY - minY);
                                            final top = relativeY * chartHeight;
                                            return Positioned(
                                              top: top - (8 * htio),
                                              left: -18 * wtio,
                                              child: SizedBox(
                                                width: 40 * wtio,
                                                child: Text(
                                                  y.toStringAsFixed(1),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: const Color(0xFFAAAAAA),
                                                    fontSize: 11 * htio,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                          Padding(
                                            padding: EdgeInsets.only(left: 27 * wtio),
                                            child: LineChart(
                                              LineChartData(
                                                minY: minY,
                                                maxY: maxY,
                                                gridData: const FlGridData(drawHorizontalLine: false, drawVerticalLine: false),
                                                titlesData: const FlTitlesData(
                                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                ),
                                                borderData: FlBorderData(show: false),
                                                lineBarsData: [
                                                  LineChartBarData(
                                                    isCurved: false,
                                                    color: const Color(0xFF0D86E7),
                                                    barWidth: 2.15 * htio,
                                                    dotData: FlDotData(
                                                      show: true,
                                                      checkToShowDot: (spot, barData) =>
                                                          showTooltip && focusedIndex != null && spot.x.toInt() == focusedIndex,
                                                    ),
                                                    belowBarData: BarAreaData(show: false),
                                                    spots: List.generate(
                                                      values.length,
                                                      (index) => FlSpot(index.toDouble(), values[index]),
                                                    ),
                                                  ),
                                                ],
                                                extraLinesData: ExtraLinesData(
                                                  extraLinesOnTop: false,
                                                  horizontalLines: yDoubles
                                                      .map((y) => HorizontalLine(
                                                            y: y,
                                                            color: const Color(0xFFEEEEEE),
                                                            strokeWidth: 1.6 * wtio,
                                                          ))
                                                      .toList(),
                                                ),
                                                lineTouchData: LineTouchData(
                                                  enabled: true,
                                                  handleBuiltInTouches: false,
                                                  touchCallback: (event, response) {
                                                    if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
                                                      final spot = response?.lineBarSpots?.first;
                                                      if (spot != null) {
                                                        setState(() {
                                                          focusedIndex = spot.x.toInt();
                                                          showTooltip = true;
                                                        });
                                                      }
                                                    } else if (event is FlLongPressEnd || event is FlPanEndEvent) {
                                                      setState(() {
                                                        showTooltip = false;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (showTooltip && focusedIndex != null)
                                            makeDetailBallon(chartWidth, chartHeight, minY, maxY, values, days),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const Spacer(flex: 18),
                            periodButtons(),
                            const Spacer(flex: 109),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Expanded periodSearchForm(BuildContext context) {
    return Expanded(
      flex: 24,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            width: 226 * wtio,
            height: 33 * htio,
            // padding: EdgeInsets.symmetric(horizontal: 12 * wtio, vertical: 12 * htio),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1 * wtio,
                        color: const Color(0xFFDDDDDD),
                    ),
                    borderRadius: BorderRadius.circular(8),
                ),
            ),
            child: SizedBox(
              height: 16 * htio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 시작일
                  datePicker(context, pickedDay: startDate, isStart: true),
                  SizedBox(width: 8 * wtio),
                  waveText(),
                  SizedBox(width: 8 * wtio),
                  // 종료일
                  datePicker(context, pickedDay: endDate, isStart: false)
                ],
              ),
            ),
        ),
      )
    );
  }

  Flexible datePicker(BuildContext context, {required DateTime pickedDay, required bool isStart}) {
    return Flexible(
      child: GestureDetector(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('yyyy.MM.dd').format(pickedDay),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14 * wtio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.5 * htio,
                letterSpacing: -0.28 * wtio,
              ),
            ),
            SizedBox(width: 4 * wtio),
            SvgPicture.asset(
              'assets/icons/calendar.svg',
              width: 16 * wtio,
              height: 16 * htio,
            ),
          ],
        ),
        onTap: () async{
          final picked = await showDayPicker(context, pickedDay);
          if (picked != null) {
            //TODO: startDate가 endDate보다 미래면 경고창 띄우며 검색시도하지 않기
            setState(() {
              if(isStart) {
                startDate = picked;
              } else {
                endDate = picked;
              }
            });
          }
        },
      ),
    );
  }

  Positioned makeDetailBallon(
     double chartWidth,
     double chartHeight,
     double minY,
     double maxY,
     List<double> values,
     List<String> days
  ){

    if (focusedIndex == null || focusedIndex! >= values.length || focusedIndex! >= days.length) {
      return const Positioned(child: SizedBox.shrink());
    }

    final chartPaddingLeft = 27 * wtio;
    final chartInnerWidth = chartWidth - chartPaddingLeft;

    final x = (chartInnerWidth / (values.length - 1)) * focusedIndex! + chartPaddingLeft;
    final balloonLeft = x - (94 * wtio) / 2;

    final weightY = values[focusedIndex!];
    final relativeY = (maxY - weightY) / (maxY - minY);
    final y = relativeY * chartHeight;
    final balloonTop = y - (120*htio); // 80: 말풍선과 데이터 점 간의 간격 (원하는 만큼 조정)


    if (showTooltip && focusedIndex != null) {
      return Positioned(
        left: balloonLeft,
        top: balloonTop,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // 선
            Positioned(
              top: 6 * htio,
              child: SvgPicture.asset(
                'assets/widgets/verticalLine.svg',
                width: 1 * wtio,
                fit: BoxFit.contain,
              ),
            ),

            // 말풍선 + 텍스트
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  'assets/widgets/message_ballon.svg',
                  width: 94 * wtio,
                  height: 64 * htio,
                  fit: BoxFit.contain,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      days[focusedIndex!],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFAAAAAA),
                        fontSize: 11 * htio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.50 * htio,
                      ),
                    ),
                    SizedBox(height: 4 * htio),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${values[focusedIndex!].toStringAsFixed(1)} ',
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 18 * htio,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.50 * htio,
                            ),
                          ),
                          TextSpan(
                            text: 'kg',
                            style: TextStyle(
                              color: const Color(0xFF777777),
                              fontSize: 18 * htio,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 1.50 *  htio,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return const Positioned(child: SizedBox.shrink());
    }
  }

  Expanded periodButtons() {
    return Expanded(
      flex: 23,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3 * wtio),
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 1 * wtio,
                    color: const Color(0xFFEEEEEE),
                ),
                borderRadius: BorderRadius.circular(8),
            ),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4 * htio,
            children: [
                periods('7일', whichButtonPush[0]),
                periods('1개월', whichButtonPush[1]),
                periods('3개월', whichButtonPush[2]),
                periods('1년', whichButtonPush[3]),
            ],
        ),
      ),
    );
  }

  Expanded periods(String text, bool isChoose) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * wtio, vertical: 10 * htio),
            decoration: ShapeDecoration(
                color: isChoose ? const Color(0xFF0D85E7) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10 * htio,
                children: [
                    SizedBox(
                        width: 58 * wtio,
                        child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isChoose ? Colors.white : Colors.black,
                                fontSize: 15 * htio,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                height: 1.20 * htio,
                            ),
                        ),
                    ),
                ],
            ),
        ),
        onTap: () {
          setState(() {
            for (int i = 0; i < whichButtonPush.length; i++) {
              whichButtonPush[i] = false;
            }
            switch (text) {
              case '7일':
                whichButtonPush[0] = true;
                startDate = endDate.subtract(const Duration(days: 7));
                break;

              case '1개월':
                whichButtonPush[1] = true;
                startDate = DateTime(
                  endDate.month == 1 ? endDate.year - 1 : endDate.year,
                  endDate.month == 1 ? 12 : endDate.month - 1,
                  _safeDay(endDate),
                );
                break;

              case '3개월':
                whichButtonPush[2] = true;
                startDate = DateTime(
                  endDate.month <= 3 ? endDate.year - 1 : endDate.year,
                  endDate.month <= 3 ? endDate.month + 9 : endDate.month - 3,
                  _safeDay(endDate),
                );
                break;

              case '1년':
                whichButtonPush[3] = true;
                startDate = DateTime(endDate.year - 1, endDate.month, _safeDay(endDate));
                break;
            }
           },);
        },
      ),
    );
  }

  int _safeDay(DateTime baseDate) {
    final year = baseDate.year;
    final month = baseDate.month;
    final lastDayOfPrevMonth = DateTime(year, month, 0).day;
    return baseDate.day > lastDayOfPrevMonth ? lastDayOfPrevMonth : baseDate.day;
  }


  Text waveText() {
    return Text(
      '~',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14 * wtio,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: -0.28 * wtio,
      ),
    );
  }

}

