import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/dialog_utils.dart' show showDayPicker;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/doc/diet/doc_diet_main.dart' show dietCalendar, dietCalendarHeader, totalKcalAndProtien;
import 'package:table_calendar/table_calendar.dart';

class DocCalendarDiet extends ConsumerStatefulWidget {
  const DocCalendarDiet({
    super.key,
    required DateTime focusedDay,
    required this.onGoToFocusedDay,
  }) : ifocusedDay = focusedDay;

  final DateTime ifocusedDay;
  final void Function({required DateTime selectedDay}) onGoToFocusedDay;

  @override
  ConsumerState<DocCalendarDiet> createState() => _DocCalendarDietState();
}

class _DocCalendarDietState extends ConsumerState<DocCalendarDiet> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  late double heightRatio;
  late double widthRatio;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.ifocusedDay;
    _focusedDay = widget.ifocusedDay;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    heightRatio = ScreenRatio(context).heightRatio;
    widthRatio = ScreenRatio(context).widthRatio;
  }

  @override
  Widget build(BuildContext context) {
    int year = _focusedDay.year;
    int month = _focusedDay.month;

    final totalInfo = ref.watch(
      selectDayDietTotal(DateFormat('yyyy-MM-dd').format(_focusedDay)),
    ).asData?.value;

    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          // 상단 날짜 영역
          SizedBox(
            height: 48 * heightRatio,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20 * widthRatio,
                right: 20 * widthRatio,
                top: 20 * heightRatio,
                bottom: 4 * heightRatio,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDayPicker(context, _focusedDay);
                    if (picked != null) {
                      setState(() {
                        _focusedDay = picked;
                        _selectedDay = picked;
                      });
                      widget.onGoToFocusedDay(selectedDay: picked);
                    }
                  },
                  child: Text(
                    '$year년 $month월',
                    key: dietCalendarHeader,
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 16 * heightRatio,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 캘린더
          SizedBox(
            height: 99 * heightRatio,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 15 * heightRatio,
                horizontal: 20 * widthRatio,
              ),
              child: TableCalendar(
                key: dietCalendar,
                headerVisible: false,
                daysOfWeekVisible: false,
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                rowHeight: 69 * heightRatio,
                focusedDay: _focusedDay.isBefore(DateTime.utc(2022, 1, 1))
                    ? DateTime.utc(2022, 1, 1)
                    : _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.week,
                availableCalendarFormats: const {CalendarFormat.week: ''},
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    widget.onGoToFocusedDay(selectedDay: selectedDay);
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, false),
                  todayBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, false),
                  selectedBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, true),
                  outsideBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, false),
                ),
              ),
            ),
          ),

          // 구분선
          Container(
            width: 335 * widthRatio,
            height: 1 * heightRatio,
            color: const Color(0xFFEEEEEE),
          ),

          // 총 섭취 칼로리/단백질
          SizedBox(
            height: 108 * heightRatio,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * widthRatio,
                vertical: 20 * heightRatio,
              ),
              child: Column(
                key: totalKcalAndProtien,
                children: [
                  makeTotal(
                    'assets/icons/kcal.svg',
                    '총 섭취 칼로리',
                    totalInfo?.totalCalorie == null
                        ? '-'
                        : '${totalInfo?.formattedTotalCalorie} kcal',
                  ),
                  SizedBox(height: 20 * heightRatio,),
                  makeTotal(
                    'assets/icons/protein.svg',
                    '총 섭취 단백질',
                    totalInfo?.totalProtein == null
                        ? '-'
                        : '${totalInfo?.formattedTotalProtein}g',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget makeTotal(String path, String text, String numunit) {
    return SizedBox(
      height: 24 * heightRatio,
      child: Row(
        children: [
          SizedBox(
            width: 20 * widthRatio,
            height: 20 * heightRatio,
            child: SvgPicture.asset(path),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8 * widthRatio),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16 * heightRatio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                numunit,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16 * heightRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isSelected) {
    final dayOfWeek =
        ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7];

    return Container(
      width: 41 * widthRatio,
      height: 69 * heightRatio,
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFF0D86E7),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 8 * heightRatio), // 상단 여백
          SizedBox(
            height: 24 * heightRatio,
            child: Text(
              day.day == 1 ? '${day.month}/${day.day}' : '${day.day}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF333333),
                fontSize: 16 * heightRatio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8 * heightRatio), // 날짜-요일 사이 여백
          SizedBox(
            height: 21 * heightRatio,
            child: Text(
              dayOfWeek,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * heightRatio,
                fontFamily: 'Pretendard',
                color:
                    isSelected ? Colors.white : Colors.black.withValues(alpha: 102),
              ),
            ),
          ),
          SizedBox(height: 8 * heightRatio), // 하단 여백
        ],
      ),
    );
  }
}
