import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_calendar/table_calendar.dart';

class DocCalendarDiet extends StatefulWidget {
  const DocCalendarDiet({
    super.key,
    required DateTime focusedDay,
  }): ifocusedDay = focusedDay;

  final DateTime ifocusedDay;

  @override
  State<DocCalendarDiet> createState() => _DocCalendarDietState();
}

class _DocCalendarDietState extends State<DocCalendarDiet> {
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
    return Expanded(
      flex:128,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: Column(
          children: [
            const Expanded(
              flex: 16,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '2025년 5월',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 33,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TableCalendar(
                  headerVisible: false,
                  daysOfWeekVisible: false,
                  firstDay: DateTime.utc(2022, 1, 1),
                  lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                  rowHeight: 69,
                  focusedDay: _focusedDay.isBefore(DateTime.utc(2022, 1, 1)) ? DateTime.utc(2022, 1, 1) : _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.week,
                  availableCalendarFormats: const {CalendarFormat.week: ''},
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
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
                    defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, false),
                    todayBuilder: (context, day, focusedDay) => _buildDayCell(day, false),
                    selectedBuilder: (context, day, focusedDay) => _buildDayCell(day, true),
                    outsideBuilder: (context, day, focusedDay) => _buildDayCell(day, false),
                  ),
                )
              ),
            ),
            Container(
                width: 335,
                height: 1,
                decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            ),
            Expanded(
              flex: 36,
              child: Padding(padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    makeTotal('assets/icons/kcal.svg', '총 섭취 칼로리', '11,650 kcal'),
                    const Spacer(flex: 5,),
                    makeTotal('assets/icons/protein.svg', '총 섭취 단백질', '120g'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),

    );
  }

  Flexible makeTotal(String path, String text, String numunit) {
    return Flexible(
      flex: 6,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              path,
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                numunit,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isSelected) {
    final dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7];

    return Container(
      width: 41,
      height: 69,
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFF0D86E7),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8), // 상단 여백
          SizedBox(
            height: 24,
            child: Text(
              day.day == 1 ? '${day.month}/${day.day}' : '${day.day}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8), // 날짜-요일 사이 여백
          SizedBox(
            height: 21,
            child: Text(
              dayOfWeek,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Pretendard',
                color: isSelected ? Colors.white : Colors.black.withValues(alpha: 102),
              ),
            ),
          ),
          const SizedBox(height: 8), // 하단 여백
        ],
      ),
    );
  }


}