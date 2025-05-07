import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/date_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class DocCalendarDiet extends ConsumerStatefulWidget {
  const DocCalendarDiet({
    super.key,
    required DateTime focusedDay,
    required this.onGoToFocusedDay
  }): ifocusedDay = focusedDay;

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

    final totalInfo = ref.watch(selectDayDietTotal(DateFormat('yyyy-MM-dd').format(_focusedDay))).asData?.value;

    return Expanded(
      flex:128,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 16,
              child: Padding(
                padding: EdgeInsets.only(left: 20 * widthRatio, right: 20 * widthRatio, top: 20 * heightRatio, bottom: 4 * heightRatio),
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
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 16 * heightRatio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.50 * heightRatio,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 33,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15 * widthRatio, horizontal: 20 * heightRatio),
                child: TableCalendar(
                  headerVisible: false,
                  daysOfWeekVisible: false,
                  firstDay: DateTime.utc(2022, 1, 1),
                  lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                  rowHeight: 69 * heightRatio,
                  focusedDay: _focusedDay.isBefore(DateTime.utc(2022, 1, 1)) ? DateTime.utc(2022, 1, 1) : _focusedDay,
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
                    defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, false),
                    todayBuilder: (context, day, focusedDay) => _buildDayCell(day, false),
                    selectedBuilder: (context, day, focusedDay) => _buildDayCell(day, true),
                    outsideBuilder: (context, day, focusedDay) => _buildDayCell(day, false),
                  ),
                )
              ),
            ),
            Container(
                width: 335 * widthRatio,
                height: 1 * heightRatio,
                decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            ),
            Expanded(
              flex: 36,
              child: Padding(padding: EdgeInsets.symmetric(horizontal: 20 * heightRatio, vertical: 20 * widthRatio),
                child: Column(
                  children: [
                    makeTotal('assets/icons/kcal.svg', '총 섭취 칼로리', totalInfo?.totalCalorie == null ? '-' : '${totalInfo?.formattedTotalCalorie} kcal'),
                    const Spacer(flex: 5,),
                    makeTotal('assets/icons/protein.svg', '총 섭취 단백질', totalInfo?.totalProtein == null ? '-' : '${totalInfo?.formattedTotalProtein}g'),
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
            width: 20 * widthRatio,
            height: 20 * heightRatio,
            child: SvgPicture.asset(
              path,
            )
          ),
          Padding(
            padding: EdgeInsets.only(left: 8 * widthRatio),
            child: AutoSizeText(
              text,
              minFontSize: 16,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16 * heightRatio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.50 * heightRatio,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: AutoSizeText(
                minFontSize: 16,
                numunit,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16 * heightRatio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50 * heightRatio,
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
                color: isSelected ? Colors.white : Colors.black.withValues(alpha: 102),
              ),
            ),
          ),
          SizedBox(height: 8 * heightRatio), // 하단 여백
        ],
      ),
    );
  }
}