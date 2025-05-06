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
                              Expanded(
                                child: LineChart(
                                  LineChartData(
                                    lineTouchData: LineTouchData(
                                      enabled: true,
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (LineBarSpot spot) => Colors.black.withAlpha(8),
                                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        tooltipMargin: 8,
                                        tooltipRoundedRadius: 8,
                                        tooltipBorder: const BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    gridData: const FlGridData(show: true),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: 0.5,
                                          getTitlesWidget: (value, meta) {
                                            return Text(value.toString());
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            int index = value.toInt();
                                           
                                            if (index < 0 || index >= days.length) return const SizedBox.shrink();
                                            return Text(days[index], style: const TextStyle(fontSize: 10));
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: true),
                                    minX: 0,
                                    maxX: (weights.length - 1).toDouble(),
                                    minY: weights.reduce((a, b) => a < b ? a : b) - 0.5,
                                    maxY: weights.reduce((a, b) => a > b ? a : b) + 0.5,
                                    lineBarsData: [
                                      LineChartBarData(
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: true),
                                        belowBarData: BarAreaData(show: false),
                                        spots: List.generate(weights.length, (index) {
                                          return FlSpot(index.toDouble(), weights[index]);
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
}

