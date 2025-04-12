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
            child: TableCalendar(
              headerVisible: false,
              daysOfWeekVisible: false,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              // calendarBuilders: CalendarBuilders(...),
            ),
          ),
        ],
      ),
    );
  }
}