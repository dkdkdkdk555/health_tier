import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app/util/date_picker.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/stc/stc_app_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class StcMain extends StatefulWidget {
  const StcMain({super.key});

  @override
  State<StcMain> createState() => _StcMainState();
}

var htio = 0.0;
var wtio = 0.0;

class _StcMainState extends State<StcMain> {
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

  final weights = [68.2, 68.0, 67.8, 67.9, 68.1];
  final days = ['2025.05.01', '2025.05.02', '2025.05.03', '2025.05.04', '2025.05.05'];

  int? focusedIndex; // weights 데이터 순번
  bool showTooltip = false; //말풍선 보여주는지 여부

  // String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 7)),);
  // String endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  List<bool> whichButtonPush = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;    

    const decVal = 0.4;

    final rawMin = weights.reduce((a, b) => a < b ? a : b);
    final rawMax = weights.reduce((a, b) => a > b ? a : b);

    // 최소/최대값
    final minY = rawMin - decVal;
    final maxY = rawMax + decVal;
    // 총 수평선 갯수
    const int lineCount = 5;

    // Y 눈금 간격 계산
    final double interval = (maxY - minY) / (lineCount - 1);
    final List<double> yDoubles = List.generate(
      lineCount,
      (i) => double.parse((minY + interval * i).toStringAsFixed(1)),
    );

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if(sizingInformation.isMobile){
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                StcAppBar(selectedIndex:_selectedIndex, onTap: _onTap,),
                Expanded(
                  flex: 329,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:20),
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

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // 수직 좌표 수치
                                        // y좌표 수치 텍스트 (수동 배치)
                                        ...yDoubles.map((y) {
                                          final relativeY = (maxY - y) / (maxY - minY);
                                          final top = relativeY * chartHeight;
                                    
                                          return Positioned(
                                            top: top - (8*htio), // 텍스트 중앙 정렬 보정
                                            left: -18 * wtio,
                                            child: SizedBox(
                                              width: 40*wtio,
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
                                        // 그래프
                                        Padding(
                                          padding: EdgeInsets.only(left: 27 * wtio,), // 좌측 수치 영역 확보
                                          child: LineChart(
                                            LineChartData(
                                              minY: minY,
                                              maxY: maxY,
                                              gridData: const FlGridData(
                                                drawHorizontalLine: false,
                                                drawVerticalLine: false,
                                              ),
                                              titlesData: const FlTitlesData(
                                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              ),
                                              borderData: FlBorderData(show: false),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  isCurved: true,
                                                  color: const Color(0xFF0D86E7),
                                                  barWidth: 2.15 * htio,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    checkToShowDot: (spot, barData) {
                                                      return showTooltip && focusedIndex != null && spot.x.toInt() == focusedIndex;
                                                    },
                                                  ),
                                                  belowBarData: BarAreaData(show: false),
                                                  spots: List.generate(weights.length, (index) {
                                                    return FlSpot(index.toDouble(), weights[index]);
                                                  }),
                                                ),
                                              ],
                                              extraLinesData: ExtraLinesData(
                                                extraLinesOnTop: false,
                                                horizontalLines: yDoubles.map((y) {
                                                  return HorizontalLine(
                                                    y: y,
                                                    color: const Color(0xFFEEEEEE),
                                                    strokeWidth: 1.6 * wtio,
                                                  );
                                                }).toList(),
                                              ),
                                              lineTouchData: LineTouchData(
                                                enabled: true,
                                                handleBuiltInTouches: false, // 기본 터치 툴팁은 끄고,
                                                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
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
                                                }
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (showTooltip && focusedIndex != null)
                                         makeDetailBallon(chartWidth, chartHeight, minY, maxY)
                                      ],
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
                  )
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
          );
        }
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
  ){

    final chartPaddingLeft = 27 * wtio;
    final chartInnerWidth = chartWidth - chartPaddingLeft;

    final x = (chartInnerWidth / (weights.length - 1)) * focusedIndex! + chartPaddingLeft;
    final balloonLeft = x - (94 * wtio) / 2;

    final weightY = weights[focusedIndex!];
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
                            text: '${weights[focusedIndex!].toStringAsFixed(1)} ',
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
              case '1개월':
                whichButtonPush[1] = true;
              case '3개월':
                whichButtonPush[2] = true;
              case '1년': 
                whichButtonPush[3] = true;
            }
           },);
        },
      ),
    );
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

