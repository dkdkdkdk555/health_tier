import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/stc/day_range_param.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class StcStampPieChart extends ConsumerWidget {
  final DayRange dayRange;

  const StcStampPieChart({super.key, required this.dayRange});

  Color? stampColor(String? stamp) {
    switch (stamp) {
      case 'terrible': return const Color(0xFFFF5656);
      case 'bad': return const Color(0xFFFF9900);
      case 'perfect': return const Color(0xFF249DFF);
      case 'normal': return const Color(0xFFFFDE23);
      case 'good': return const Color(0xFF95D33E);
      default: return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var htio = ScreenRatio(context).heightRatio;
    var wtio = ScreenRatio(context).widthRatio;    

    final stampList = ref.watch(selectStampList(dayRange));

    return Expanded(
      flex: 124,
      child: stampList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('에러 발생: $err')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('데이터 없음'));
      
          final countMap = <String, int>{};
          for (var item in list) {
            countMap[item.stamp] = (countMap[item.stamp] ?? 0) + 1;
          }
      
          final total = list.length;
          final keys = countMap.keys.toList();
      
          return Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 247, 222)
            ),
            child: Row(
              children: [
                // 도넛 차트 영역
                Expanded(
                  flex: 10, // 전체 10 중 6 비율
                  child: AspectRatio(
                    aspectRatio: 1, // 정사각형 유지
                    child: Padding(
                      padding: EdgeInsets.all(12 * wtio),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2 * htio,
                          centerSpaceRadius: 40 * htio,
                          sections: List.generate(countMap.length, (i) {
                            final stamp = keys[i];
                            final value = countMap[stamp]!;
                            final percent = (value / total * 100).round();
                            return PieChartSectionData(
                              color: stampColor(stamp),
                              value: value.toDouble(),
                              title: '$percent%',
                              titleStyle: TextStyle(
                                fontSize: 14 * htio,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 60 * htio,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                // 범례 영역
                Expanded(
                  flex: 4, // 전체 10 중 4 비율
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * wtio),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(countMap.length, (i) {
                        final stamp = keys[i];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4 * htio),
                          child: Row(
                            children: [
                              Container(
                                width: 14 * wtio,
                                height: 14 * htio,
                                color: stampColor(stamp),
                              ),
                              SizedBox(width: 6 * wtio),
                              Text(
                                stamp.isEmpty ? 'none' : stamp,
                                style: TextStyle(fontSize: 14 * htio),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
