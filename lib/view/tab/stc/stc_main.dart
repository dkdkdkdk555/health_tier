import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/stc/stc_app_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class StcMain extends StatefulWidget {
  const StcMain({super.key});

  @override
  State<StcMain> createState() => _StcMainState();
}

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
                                width: 207,
                                height: 33,
                                padding: const EdgeInsets.all(12),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFFDDDDDD),
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
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData( // 눈금선
                                      drawHorizontalLine: true, drawVerticalLine: false,
                                      horizontalInterval: 0.5,
                                      getDrawingHorizontalLine: (value) => const FlLine(
                                        color: Color(0xFFEEEEEE),
                                        strokeWidth: 1.6,
                                      ),
                                    ), 
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles( // 왼쪽에 표시될 수치
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: 0.5,
                                          getTitlesWidget: (value, meta) {
                                            return Text(value.toString());
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles( // 밑에 표시될 수치
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            int index = value.toInt();
                                            if (index < 0 || index >= days.length) return const SizedBox.shrink();
                                            return Text(days[index], style: const TextStyle(fontSize: 10));
                                          },
                                        ),
                                      ),
                                      // 오른쪽, 상단 수치는 표시안함
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false), // 테두리
                                    minX: 0,
                                    maxX: (weights.length - 1).toDouble(),
                                    minY: weights.reduce((a, b) => a < b ? a : b) - 0.5,
                                    maxY: weights.reduce((a, b) => a > b ? a : b) + 0.5,
                                    lineBarsData: [
                                      LineChartBarData(
                                        isCurved: true,
                                        color: const Color(0xFF0D86E7),
                                        barWidth: 3,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(show: false), // 그래프 밑 영역의 넓이 표시여부
                                        spots: List.generate(weights.length, (index) {
                                          return FlSpot(index.toDouble(), weights[index]);
                                        }),
                                      ),
                                    ],
                                    lineTouchData: LineTouchData(
                                      enabled: true,
                                      touchTooltipData: LineTouchTooltipData(
                                        tooltipRoundedRadius: 8,
                                        tooltipMargin: 12,
                                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        tooltipBorder: BorderSide.none,
                                        getTooltipColor: (spot) => Colors.black.withAlpha(204),
                                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            return LineTooltipItem(
                                              '${days[spot.x.toInt()]}\n${weights[spot.x.toInt()]} kg', // 텍스트 표시
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(flex:15),
                              periodButtons(),
                              const Spacer(flex: 109,)
                            ],
                          )
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
        // padding: const EdgeInsets.all(4),
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
            spacing: 4,
            children: [
                Container(
                    width: 78,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                            SizedBox(
                                width: 58,
                                child: Text(
                                    '7일',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 1.20,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
                Container(
                    width: 79,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                            Text(
                                '1개월',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    height: 1.20,
                                ),
                            ),
                        ],
                    ),
                ),
                Container(
                    width: 79,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                        color: const Color(0xFF0D85E7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                            Text(
                                '3개월',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    height: 1.20,
                                ),
                            ),
                        ],
                    ),
                ),
                Container(
                    width: 79,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                            SizedBox(
                                width: 59,
                                child: Text(
                                    '1년',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 1.20,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        ),
      ),
    );
  }
}

