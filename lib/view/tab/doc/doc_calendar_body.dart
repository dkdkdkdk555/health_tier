import 'package:flutter/material.dart';
import 'package:my_app/view/tab/doc/doc_body_detail.dart' show DocBodyDetail;
import 'package:table_calendar/table_calendar.dart';

class DocCalendarBody extends StatefulWidget {
  const DocCalendarBody({super.key});

  @override
  State<DocCalendarBody> createState() => _DocCalendarBodyState();
}

class _DocCalendarBodyState extends State<DocCalendarBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 201,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            // headerStyle: HeaderStyle(...),
            // daysOfWeekStyle: DaysOfWeekStyle(...),
            // calendarBuilders: CalendarBuilders(...),
          )
          // Container(
          //   color: const Color(0xFFF5F5F5)
          // )
        ),
        const DocBodyDetail(),
      ],
    );
  }
}