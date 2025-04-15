import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/model/doc_main_model.dart' show DocDayInfo;
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_daysofweek.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalenderBody extends ConsumerWidget {
  const CustomCalenderBody({
    super.key,
    required DateTime focusedDay,
  }) : _focusedDay = focusedDay;

  final DateTime _focusedDay;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearMonth = DateFormat('yyyy-MM').format(_focusedDay);
    final screenHeight = MediaQuery.of(context).size.height;
    final heightRatio = screenHeight / 812.0;
    final dayDocList = ref.watch(htDayDocOfMonth(yearMonth));

    return Expanded(
      flex: 169,
      child: Column(
        children: [
          const Expanded(
            flex: 23,
            child: CustomWeekdayRow()
          ),
          Expanded(
            flex: 146,
            child: Row(
              children: [
                const Spacer(flex: 3,),
                Expanded(
                  flex: 67,
                  child: TableCalendar(
                    headerVisible: false,
                    daysOfWeekVisible: false,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    rowHeight: 48.25 * heightRatio,
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, _) => buildDayCell(context, date, dayDocList: dayDocList),
                      outsideBuilder: outsideDayForm,
                    ),
                  ),
                ),
                const Spacer(flex: 3,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDayCell(
    BuildContext context,
    DateTime date, {
    required AsyncValue<List<DocDayInfo>> dayDocList,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final heightRatio = screenHeight / 812.0;
    final widthRatio = screenWidth / 375.0;

    final topPadding = 2.0 * heightRatio;
    final textBoxHeight = 17.0 * heightRatio;
    final bottomPadding = 29.0 * heightRatio;

    Color? stampColor(String? stamp) {
      switch (stamp) {
        case 'TERRIBLE': return const Color(0xFFFF5656);
        case 'BAD': return const Color(0xFFFF9900);
        case 'PERFECT': return const Color(0xFF249DFF);
        case 'NORMAL': return const Color(0xFFFFDE23);
        case 'GOOD': return const Color(0xFF95D33E);
        default: return const Color(0xFFF5F5F5);
      }
    }

    return dayDocList.when(
      data: (list) {
        final matched = list.firstWhere(
          (item) => item.day == DateFormat('yyyy-MM-dd').format(date),
          orElse: () => DocDayInfo(day: '', weight: null, totalCalorie: null),
        );

        final bgColor = stampColor(matched.stamp);

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Column(
                children: [
                  SizedBox(height: topPadding),
                  SizedBox(
                    height: textBoxHeight,
                    child: Center(
                      child: AutoSizeText(
                        '${date.day}',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11.0 * heightRatio,
                          color:Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: bottomPadding,
                    child: Column(
                      children: [
                        if (matched.weight != null)
                          _infoBox('${matched.weight}', 'kg', widthRatio, heightRatio)
                        else
                            Container( width: 46 * widthRatio, height: 13 * heightRatio, margin: const EdgeInsets.only(bottom: 1)),
                        if (matched.totalCalorie != null)
                          _infoBox('${matched.totalCalorie!.round()}', 'kcal', widthRatio, heightRatio),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ).withBackground(bgColor);
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  } 

  Widget? outsideDayForm(context, date, _) {
    final screenHeight = MediaQuery.of(context).size.height;

    // 기준 디바이스 height: 932 기준 비율
    final heightRatio = screenHeight / 812.0;

    // 실제 높이 계산
    final topPadding = 2.0 * heightRatio;
    final textBoxHeight = 17.0 * heightRatio;
    final bottomPadding = 29.0 * heightRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            children: [
              SizedBox(height: topPadding),
              SizedBox(
                height: textBoxHeight,
                child: Center(
                  child: AutoSizeText(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11.0 * heightRatio, // 반응형 폰트
                      color: Colors.black.withValues(alpha: 0.1)
                    ),
                  ),
                ),
              ),
              SizedBox(height: bottomPadding,child: Container(),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _infoBox(String value, String unit, double widthRatio, double heightRatio) {
    return Container(
      width: 46 * widthRatio,
      height: 13 * heightRatio,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.31), // 30% 투명도
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5 * widthRatio,
                  fontFamily: 'Pretendard',
                ),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.69), // 70% 투명도
                  fontSize: 9.5 * widthRatio,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

extension WidgetBackgroundExtension on Widget {
  Widget withBackground(Color? color) {
    if (color == null) return this;
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(4))
      ),
      child: this,
    );
  }
}
