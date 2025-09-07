import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app/model/stc/day_range_param.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog, showDayPicker;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/stc/stc_app_bar.dart';
import 'package:my_app/view/tab/stc/stc_graph_line.dart';
import 'package:my_app/view/tab/stc/stc_graph_pie.dart';
import 'package:responsive_builder/responsive_builder.dart';

class StcMain extends ConsumerStatefulWidget {
  const StcMain({super.key});

  @override
  ConsumerState<StcMain> createState() => _StcMainState();
}

var htio = 0.0;
var wtio = 0.0;

class _StcMainState extends ConsumerState<StcMain> {
  late int _selectedIndex;
  List<bool> whichButtonPush = [true, false, false, false]; 
  var startDate = cachedDayRange.getStartDay();
  var endDate = cachedDayRange.getEndDay();

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedStcTabIndex;
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedStcTabIndex = index;
    });
  }

  void _onDateRangeChanged(DateTime newStart, DateTime newEnd) {
    cachedDayRange = DayRange(
      DateFormat('yyyy-MM-dd').format(newStart),
      DateFormat('yyyy-MM-dd').format(newEnd),
    );
  }

  void _onBtnPushedChanged(int num) {
    cachedStcBtnPushed = num;
  }

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    final param = cachedDayRange;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          StcAppBar(selectedIndex: _selectedIndex, onTap: _onTap),
          SizedBox(height: 15 * htio),
          Row(
            children: [
              SizedBox(width: 20 * wtio),
              periodSearchForm(context, htio, wtio),
            ],
          ),
          SizedBox(height: 68 * htio),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
              child: Column(
                children: [
                  _selectedIndex != 3 
                    ? StcGraphLine(dayRange: param, tabIndex: _selectedIndex)
                    : StcStampPieChart(dayRange: param),
                  SizedBox(height: 16 * htio),
                  periodButtons(htio, wtio),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget periodSearchForm(BuildContext context, double htio, double wtio) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 33 * htio,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * wtio),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1 * wtio, color: const Color(0xFFDDDDDD)),
              borderRadius: BorderRadius.circular(8 * wtio),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              datePicker(context, pickedDay: startDate, isStart: true, htio: htio, wtio: wtio),
              SizedBox(width: 8 * wtio),
              waveText(wtio),
              SizedBox(width: 8 * wtio),
              datePicker(context, pickedDay: endDate, isStart: false, htio: htio, wtio: wtio),
            ],
          ),
        ),
      ),
    );
  }

  Widget datePicker(BuildContext context, {required DateTime pickedDay, required bool isStart, required double htio, required double wtio}) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDayPicker(context, pickedDay);
        if (picked != null) {
          final newStart = isStart ? picked : startDate;
          final newEnd = isStart ? endDate : picked;
          final diff = newEnd.difference(newStart).inDays;
          if (diff > 365) {
            if (!context.mounted) return;
            showAppDialog(context, message: '조회 기간은 최대 1년까지 선택할 수 있습니다.', confirmText: '확인');
            return;
          }
          setState(() {
            if (isStart) startDate = picked;
            else endDate = picked;
            _onDateRangeChanged(startDate, endDate);
          });
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AutoSizeText(
            DateFormat('yyyy.MM.dd').format(pickedDay),
            style: TextStyle(
              fontSize: 14 * htio,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              height: 1.5 * htio,
            ),
          ),
          SizedBox(width: 4 * wtio),
          SvgPicture.asset('assets/icons/calendar.svg', width: 16 * wtio, height: 16 * htio),
        ],
      ),
    );
  }

  Widget waveText(double wtio) {
    return Text(
      '~',
      style: TextStyle(
        fontSize: 14 * wtio,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget periodButtons(double htio, double wtio) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3 * wtio, vertical: 4 * htio),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1 * wtio, color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(8 * wtio),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          periods('7일', whichButtonPush[0], 0, htio, wtio),
          periods('1개월', whichButtonPush[1], 1, htio, wtio),
          periods('3개월', whichButtonPush[2], 2, htio, wtio),
          periods('1년', whichButtonPush[3], 3, htio, wtio),
        ],
      ),
    );
  }

  Widget periods(String text, bool isChoose, int index, double htio, double wtio) {
    var selectedColor = _selectedIndex == 0 ? const Color(0xFF0D86E7)
                        : _selectedIndex == 1 ? const Color(0xFF95D33E) 
                        : _selectedIndex == 2 ? const Color(0xFFFFDE23)
                        : const Color(0xFF000000);

    isChoose = cachedStcBtnPushed == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            for (int i = 0; i < whichButtonPush.length; i++) whichButtonPush[i] = false;
            whichButtonPush[index] = true;

            switch (text) {
              case '7일':
                startDate = endDate.subtract(const Duration(days: 7));
                _onBtnPushedChanged(0);
                break;
              case '1개월':
                startDate = DateTime(
                  endDate.month == 1 ? endDate.year - 1 : endDate.year,
                  endDate.month == 1 ? 12 : endDate.month - 1,
                  _safeDay(endDate),
                );
                _onBtnPushedChanged(1);
                break;
              case '3개월':
                startDate = DateTime(
                  endDate.month <= 3 ? endDate.year - 1 : endDate.year,
                  endDate.month <= 3 ? endDate.month + 9 : endDate.month - 3,
                  _safeDay(endDate),
                );
                _onBtnPushedChanged(2);
                break;
              case '1년':
                startDate = DateTime(endDate.year - 1, endDate.month, _safeDay(endDate));
                _onBtnPushedChanged(3);
                break;
            }
            _onDateRangeChanged(startDate, endDate);
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * wtio, vertical: 10 * htio),
          decoration: ShapeDecoration(
            color: isChoose ? selectedColor : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * wtio)),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isChoose ? Colors.white : Colors.black,
                fontSize: 15 * htio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _safeDay(DateTime baseDate) {
    final year = baseDate.year;
    final month = baseDate.month;
    final lastDayOfPrevMonth = DateTime(year, month, 0).day;
    return baseDate.day > lastDayOfPrevMonth ? lastDayOfPrevMonth : baseDate.day;
  }
}
