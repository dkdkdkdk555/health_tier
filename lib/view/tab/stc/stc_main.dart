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
    const int lineCount = 5;

    // Y 눈금 간격 계산
    final double interval = (maxY - minY) / (lineCount - 1);
    final List<double> yDoubles = List.generate(
      lineCount,
      (i) => double.parse((minY + interval * i).toStringAsFixed(1)),
    );

    yDoubles.forEach((e) => debugPrint('e : $e'));

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

                                        Positioned(
                                          top: 50,
                                          left: 120,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/widgets/message_ballon.svg', // 말풍선, 배너 등 원하는 SVG 파일
                                                width: 94,
                                                height: 64,
                                                fit: BoxFit.contain,
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text(
                                                    '2025.02.06',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(0xFFAAAAAA),
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
                                                            color: const Color(0xFF333333),
                                                            fontSize: 18,
                                                            fontFamily: 'Pretendard',
                                                            fontWeight: FontWeight.w700,
                                                            height: 1.50,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'kg',
                                                          style: TextStyle(
                                                            color: const Color(0xFF777777),
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
                                              SvgPicture.asset(
                                                'assets/widgets/verticalLine.svg', // 말풍선, 배너 등 원하는 SVG 파일
                                                width: 1,
                                                fit: BoxFit.contain,
                                              ),
                                            ],
                                          ),
                                        ),

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
                                                  dotData: const FlDotData(show: false),
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
                                                      final index = spot.x.toInt();
                                                      if (index >= 0 && index < weights.length) {
                                                        final day = days[index];
                                                        final weight = weights[index];
                                                        debugPrint('👉 $day - $weight kg 선택됨');

                                                        // TODO: 여기서 커스텀 UI 표시 로직 실행 (예: setState로 상태 업데이트)
                                                      }
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
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

