import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  final days = ['05.01', '05.02', '05.03', '05.04', '05.05'];

  int? focusedIndex;
  bool showTooltip = false;

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

    // debugPrint("$_selectedIndex");
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
                        Expanded(
                          flex: 24,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                                width: 207 * wtio,
                                height: 33 * htio,
                                padding: EdgeInsets.symmetric(horizontal: 12 * wtio, vertical: 12 * htio),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1 * wtio,
                                            color: const Color(0xFFDDDDDD),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                    ),
                                ),
                            ),
                          )
                        ),
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
                                                  color: Color(0xFFAAAAAA),
                                                  fontSize: 11 * htio,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
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

  Positioned makeDetailBallon(
     double chartWidth,
     double chartHeight,
     double minY,
     double maxY,
  ){

    final chartPaddingLeft = 27 * wtio;
    final chartInnerWidth = chartWidth - chartPaddingLeft;

    final x = (chartInnerWidth / (weights.length - 1)) * focusedIndex! + chartPaddingLeft;
    final balloonLeft = x - 94 / 2;

    final weightY = weights[focusedIndex!];
    final relativeY = (maxY - weightY) / (maxY - minY);
    final y = relativeY * chartHeight;
    final balloonTop = y - 80; // 80: 말풍선과 데이터 점 간의 간격 (원하는 만큼 조정)


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
              top: 64 - 58,
              child: SvgPicture.asset(
                'assets/widgets/verticalLine.svg',
                width: 1,
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
                  width: 94,
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '2025.02.06',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 11,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '72.8 ',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 18,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                          TextSpan(
                            text: 'kg',
                            style: TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 18,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
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
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                side: const BorderSide(
                    width: 1,
                    color: Color(0xFFEEEEEE),
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
                periods('7일'),
                periods('1개월'),
                periods('3개월'),
                periods('1년'),
            ],
        ),
      ),
    );
  }

  Expanded periods(String text) {
    return Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * wtio, vertical: 10 * htio),
          decoration: ShapeDecoration(
              color: Colors.white,
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
                              color: Colors.black,
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
    );
  }

}

