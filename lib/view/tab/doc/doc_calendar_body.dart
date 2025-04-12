import 'package:flutter/material.dart';
import 'package:my_app/view/tab/doc/calendar/calendar_header.dart';
import 'package:my_app/view/tab/doc/doc_body_detail.dart' show DocBodyDetail;
import 'package:table_calendar/table_calendar.dart';

class DocCalendarBody extends StatefulWidget {
  const DocCalendarBody({super.key});

  @override
  State<DocCalendarBody> createState() => _DocCalendarBodyState();
}

class _DocCalendarBodyState extends State<DocCalendarBody> {
   DateTime _focusedDay = DateTime.now();

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 201,
          child: Column(
            children: [
              CustomCalendarHeader(
                focusedDay: _focusedDay,
                onLeftArrow: _goToPreviousMonth,
                onRightArrow: _goToNextMonth,
              ),
              Expanded(
                flex: 169,
                child: TableCalendar(
                  headerVisible: false,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  // headerStyle: HeaderStyle(...),
                  // daysOfWeekStyle: DaysOfWeekStyle(...),
                  // calendarBuilders: CalendarBuilders(...),
                ),
              ),
            ],
          )
        ),
        const DocBodyDetail(),
      ],
    );
  }
}