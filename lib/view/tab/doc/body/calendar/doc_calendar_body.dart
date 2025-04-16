import 'package:flutter/material.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_body.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_header.dart';
import 'package:my_app/view/tab/doc/body/doc_body_detail.dart' show DocBodyDetail;

class DocCalendarBody extends StatefulWidget {
  const DocCalendarBody({super.key});

  @override
  State<DocCalendarBody> createState() => _DocCalendarBodyState();
}

class _DocCalendarBodyState extends State<DocCalendarBody> {
   DateTime _focusedDay = DateTime.now();

  void _goToPreviousMonth({DateTime? selectedDay}) {
    setState(() {
      if(selectedDay != null){
        _focusedDay = selectedDay;
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
      }
    });
  }

  void _goToNextMonth({DateTime? selectedDay}) {
    setState(() {
      if(selectedDay != null){
        _focusedDay = selectedDay;
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
      }
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
              CustomCalenderBody(focusedDay: _focusedDay, onGoToNextMonth: _goToNextMonth, onGoToPreviousMonth: _goToPreviousMonth,),
            ],
          )
        ),
        DocBodyDetail(focusedDay: _focusedDay,),
      ],
    );
  }
}

