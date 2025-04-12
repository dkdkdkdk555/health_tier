import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:my_app/view/tab/doc/calendar/calendar_daysofweek.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalenderBody extends StatelessWidget {
  const CustomCalenderBody({
    super.key,
    required DateTime focusedDay,
  }) : _focusedDay = focusedDay;

  final DateTime _focusedDay;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heightRatio = screenHeight / 812.0;
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
                  child: Container(
                    // color: Colors.red.withOpacity(0.1),
                    child: TableCalendar(
                      headerVisible: false,
                      daysOfWeekVisible: false,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      rowHeight: 48.25 * heightRatio,
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: defaultDayForm,
                        outsideBuilder: (context, date, _) => defaultDayForm(context, date, _, isOutside: true),
                      ),
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

  Widget? defaultDayForm(context, date, _, {bool isOutside = false}) {
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
                      color: isOutside
                          ? Colors.black.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: bottomPadding,
                child: Container(
                  // color: Colors.blue.withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}