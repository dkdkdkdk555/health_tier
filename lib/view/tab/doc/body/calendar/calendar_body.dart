import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/model/doc_main_model.dart' show DocDayInfo;
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_daysofweek.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalenderBody extends ConsumerStatefulWidget{
  const CustomCalenderBody({
    super.key,
    required DateTime focusedDay,
    required this.onGoToPreviousMonth,
    required this.onGoToNextMonth,
  }) : ifocusedDay = focusedDay;

  final DateTime ifocusedDay;
  final VoidCallback onGoToPreviousMonth;
  final VoidCallback onGoToNextMonth;

  @override
  ConsumerState<CustomCalenderBody> createState() => _CustomCalenderBodyState();
}

class _CustomCalenderBodyState extends ConsumerState<CustomCalenderBody> {

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.ifocusedDay;
    _focusedDay = widget.ifocusedDay;
  }


  @override
  Widget build(BuildContext context) {
    _focusedDay = widget.ifocusedDay; // CustomCalendarHeader 에서 nextMonth, prevMonth 경우 업데이트
    final yearMonth = DateFormat('yyyy-MM').format(_focusedDay);
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
                    firstDay: DateTime.utc(2022, 1, 1),
                    lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                    rowHeight: 48.25 * ScreenRatio(context).heightRatio,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    onDaySelected: (selectedDay, focusedDay){
                      setState((){
                        // outside cell 선택 시 이전/다음 달로 이동
                        if (selectedDay.month < _focusedDay.month) {
                          // 이전 달
                          widget.onGoToPreviousMonth();
                        } else if (selectedDay.month > _focusedDay.month) {
                          // 다음 달
                          widget.onGoToNextMonth();
                        }
                        _selectedDay = selectedDay;
                        _focusedDay = selectedDay;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      todayBuilder:  (context, date, _) => buildDayCell(context, date, dayDocList: dayDocList),
                      selectedBuilder: (context, date, _) => buildDayCell(context, date, dayDocList: dayDocList, isSelected: true),
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
      DateTime date, 
      {
        required AsyncValue<List<DocDayInfo>> dayDocList,
        bool isSelected = false
      }
    ) {
    
    final heightRatio = ScreenRatio(context).heightRatio;
    final widthRatio = ScreenRatio(context).widthRatio;
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
                    child: Container(
                        margin: EdgeInsets.only(bottom:1 * heightRatio),
                        decoration: isSelected ? const BoxDecoration(shape: BoxShape.circle, color: Colors.white) : null,
                        child: Center(
                        child: AutoSizeText(
                          '${date.day}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11.0 * heightRatio,
                            color: isSelected ? Colors.black : Colors.black.withValues(alpha: 0.5),
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: bottomPadding,
                    child: Column(
                      children: [
                        if (matched.weight != null)
                          _infoBox('${matched.weight}', 'kg')
                        else
                            Container( width: 46 * widthRatio, height: 13 * heightRatio, margin: const EdgeInsets.only(bottom: 1)),
                        if (matched.totalCalorie != null)
                          _infoBox('${matched.totalCalorie!.round()}', 'kcal'),
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

    final heightRatio = ScreenRatio(context).heightRatio;
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


  Widget _infoBox(String value, String unit) {
    final heightRatio = ScreenRatio(context).heightRatio;
    final widthRatio = ScreenRatio(context).widthRatio;
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
