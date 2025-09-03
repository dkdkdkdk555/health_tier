import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/model/stc/day_range_param.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/common/error_widget.dart';

class StcGraphLine extends ConsumerStatefulWidget {
  final DayRange dayRange;
  final int tabIndex;

  const StcGraphLine({
    super.key,
    required this.dayRange,
    required this.tabIndex
  });

  @override
  ConsumerState<StcGraphLine> createState() => _StcGraphLineState();
}

var htio = 0.0;
var wtio = 0.0;

class _StcGraphLineState extends ConsumerState<StcGraphLine> {

  int? focusedIndex; // weights 데이터 순번
  bool showTooltip = false; //말풍선 보여주는지 여부


  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;


    final stcList = switch (widget.tabIndex) {
      0 => ref.watch(selectWeightList(widget.dayRange)),
      1 => ref.watch(selectMuscleList(widget.dayRange)),
      2 => ref.watch(selectFatList(widget.dayRange)),
      _ => throw Exception('Invalid tabIndex')
    };

    return Expanded(
      flex: 124,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartHeight = constraints.maxHeight;
          final chartWidth = constraints.maxWidth;

          return stcList.when(
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (err, stack) => const ErrorContentWidget(),
            data: (list) {
              if (list.isEmpty) {
                return const Center(child: Text('데이터가 없습니다'));
              }

              final values = list.map((e) => e.value).toList();
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
                            color: widget.tabIndex == 0 ? const Color(0xFF0D86E7)
                              : widget.tabIndex == 1 ? const Color(0xFF95D33E) 
                              : const Color(0xFFFFDE23),
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
    final weightY = values[focusedIndex!];
    final relativeY = (maxY - weightY) / (maxY - minY);
    final y = relativeY * chartHeight;
    final balloonTop = y - (120*htio); // 80: 말풍선과 데이터 점 간의 간격 (원하는 만큼 조정)

    final balloonWidth = 94.0 * wtio;
    double balloonLeft = x - (balloonWidth) / 2;

    String balloonAsset = 'assets/widgets/message_balloon.svg';

    if (balloonLeft < -10 *wtio) {
      balloonLeft = 15 * wtio;
      balloonAsset = 'assets/widgets/message_balloon_left.svg';
    } else if ((balloonLeft + balloonWidth)-(40*wtio) > chartWidth) {
      balloonLeft = (chartWidth - balloonWidth) + (10 *wtio);
      balloonAsset = 'assets/widgets/message_balloon_right.svg';
    }


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
              left: () {
                switch (balloonAsset) {
                  case 'assets/widgets/message_balloon_left.svg':
                    return 10 * wtio;
                  case 'assets/widgets/message_balloon_right.svg':
                    return balloonWidth - 10 * wtio;
                  default:
                    return balloonWidth / 2;
                }
              }(),
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
                  balloonAsset,
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
                            text: widget.tabIndex != 2 ? 'kg' : '%',
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

}