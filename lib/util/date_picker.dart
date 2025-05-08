import 'package:flutter/material.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:table_calendar/table_calendar.dart';

Future<DateTime?> showDayPicker(BuildContext context, DateTime initialDate, ) {
    final double heightRatio = ScreenRatio(context).heightRatio;
    final double widthRatio = ScreenRatio(context).widthRatio;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime selectedDate = initialDate;

        return Dialog(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 400 * heightRatio,
                      width: 350 * widthRatio,
                      child: TableCalendar(
                        locale: 'ko_KR',
                        rowHeight: 50 * heightRatio,
                        daysOfWeekHeight: 20 * heightRatio,
                        firstDay: DateTime(2022, 1, 1),
                        lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                        focusedDay: selectedDate,
                        selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                        onDaySelected: (day, _) {
                          Navigator.of(context).pop(day); // ← day로 수정하는 게 맞음
                        },
                        onPageChanged: (day) => setState(() => selectedDate = day),
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: '', // ← 드롭다운 제거
                        },
                        headerStyle: const HeaderStyle(
                          titleCentered: true, // ← 년월 가운데 정렬
                          formatButtonVisible: false, // ← format 드롭다운 숨기기
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }