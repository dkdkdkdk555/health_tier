import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/stc/day_range_param.dart';
import 'package:my_app/providers/db_providers.dart';

class StcStampPieChart extends ConsumerWidget {
  final DayRange dayRange;

  const StcStampPieChart({super.key, required this.dayRange});

  Color? stampColor(String? stamp) {
    debugPrint('스탬프: $stamp');
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
      
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 도넛 차트
              SizedBox(
                width: 180,
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(countMap.length, (i) {
                      final stamp = keys[i];
                      final value = countMap[stamp]!;
                      final percent = (value / total * 100).round();
                      return PieChartSectionData(
                        color: stampColor(stamp),
                        value: value.toDouble(),
                        title: '$percent%',
                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        radius: 60,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 범례
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(countMap.length, (i) {
                  final stamp = keys[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 14, height: 14, color: stampColor(stamp)),
                        const SizedBox(width: 6),
                        Text(stamp == '' ? 'none' : stamp, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
