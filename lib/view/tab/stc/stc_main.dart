import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app/model/stc/day_range_param.dart';
import 'package:my_app/util/date_picker.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/stc/stc_app_bar.dart';
import 'package:my_app/view/tab/stc/stc_graph_line.dart';
import 'package:my_app/view/tab/stc/stc_graph_pie.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class StcMain extends ConsumerStatefulWidget {
  const StcMain({super.key});

  @override
  ConsumerState<StcMain> createState() => _StcMainState();
}

var htio = 0.0;
var wtio = 0.0;

class _StcMainState extends ConsumerState<StcMain> {
  // 어느 하위 탭인지
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedStcTabIndex; // 캐시된 값 불러오기
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedStcTabIndex = index; // 캐싱
    });
  }


  List<bool> whichButtonPush = [true, false, false, false]; // 기간조회버튼 4가지의 

  void _onDateRangeChanged(DateTime newStart, DateTime newEnd) {
    cachedDayRange = DayRange(
      DateFormat('yyyy-MM-dd').format(newStart),
      DateFormat('yyyy-MM-dd').format(newEnd),
    );
  }

  void _onBtnPushedChanged(int num){
    cachedStcBtnPushed = num;
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    final param = cachedDayRange;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              StcAppBar(selectedIndex: _selectedIndex, onTap: _onTap),
              Expanded(
                flex: 329,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      periodSearchForm(context),
                      Expanded(
                        flex: 305,
                        child: Column(
                          children: [
                            const Spacer(flex: 34),
                            _selectedIndex != 3 
                              ? StcGraphLine(dayRange: param, tabIndex: _selectedIndex,) 
                              : StcStampPieChart(dayRange: param,),
                            const Spacer(flex: 18),
                            periodButtons(),
                            const Spacer(flex: 109),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Expanded periodSearchForm(BuildContext context) {
    return Expanded(
      flex: 24,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            width: 226 * wtio,
            height: 33 * htio,
            // padding: EdgeInsets.symmetric(horizontal: 12 * wtio, vertical: 12 * htio),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1 * wtio,
                        color: const Color(0xFFDDDDDD),
                    ),
                    borderRadius: BorderRadius.circular(8),
                ),
            ),
            child: SizedBox(
              height: 16 * htio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 시작일
                  datePicker(context, pickedDay: cachedDayRange.getStartDay(), isStart: true),
                  SizedBox(width: 8 * wtio),
                  waveText(),
                  SizedBox(width: 8 * wtio),
                  // 종료일
                  datePicker(context, pickedDay: cachedDayRange.getEndDay(), isStart: false)
                ],
              ),
            ),
        ),
      )
    );
  }

  Flexible datePicker(BuildContext context, {required DateTime pickedDay, required bool isStart}) {
    return Flexible(
      child: GestureDetector(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              DateFormat('yyyy.MM.dd').format(pickedDay),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14 * wtio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.5 * htio,
                letterSpacing: -0.28 * wtio,
              ),
            ),
            SizedBox(width: 4 * wtio),
            SvgPicture.asset(
              'assets/icons/calendar.svg',
              width: 16 * wtio,
              height: 16 * htio,
            ),
          ],
        ),
        onTap: () async {
          final picked = await showDayPicker(context, pickedDay);
          if (picked != null) {
            final newStart = isStart ? picked : startDate;
            final newEnd = isStart ? endDate : picked;
            final diff = newEnd.difference(newStart).inDays;

            if (diff > 365) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('기간 제한'),
                  content: const Text('조회 기간은 최대 1년까지 선택할 수 있습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
              return; // 선택 무시
            }

            setState(() {
              if (isStart) {
                startDate = picked;
              } else {
                endDate = picked;
              }
              _onDateRangeChanged(startDate, endDate);
            });
          }
        }
      ),
    );
  }

  Expanded periodButtons() {
    return Expanded(
      flex: 23,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3 * wtio),
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 1 * wtio,
                    color: const Color(0xFFEEEEEE),
                ),
                borderRadius: BorderRadius.circular(8),
            ),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4 * htio,
            children: [
                periods('7일', whichButtonPush[0], 0),
                periods('1개월', whichButtonPush[1], 1),
                periods('3개월', whichButtonPush[2], 2),
                periods('1년', whichButtonPush[3], 3),
            ],
        ),
      ),
    );
  }

  Expanded periods(String text, bool isChoose, int index) {
    var selectedColor = _selectedIndex == 0 ? const Color(0xFF0D86E7)
                        : _selectedIndex == 1 ? const Color(0xFF95D33E) 
                        : _selectedIndex == 2 ? const Color(0xFFFFDE23)
                        : const Color(0xFF000000);

    if(cachedStcBtnPushed == index) {
      isChoose = true;
    } else {
      isChoose = false;
    }

    return Expanded(
      flex: 1,
      child: GestureDetector(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * wtio, vertical: 10 * htio),
            decoration: ShapeDecoration(
                color: isChoose ? selectedColor : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10 * htio,
                children: [
                    SizedBox(
                        width: 58 * wtio,
                        child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isChoose ? Colors.white : Colors.black,
                                fontSize: 15 * htio,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                height: 1.20 * htio,
                            ),
                        ),
                    ),
                ],
            ),
        ),
        onTap: () {
          setState(() {
            for (int i = 0; i < whichButtonPush.length; i++) {
              whichButtonPush[i] = false;
            }
            switch (text) {
              case '7일':
                whichButtonPush[0] = true;
                startDate = endDate.subtract(const Duration(days: 7));
                _onBtnPushedChanged(0);
                break;

              case '1개월':
                whichButtonPush[1] = true;
                startDate = DateTime(
                  endDate.month == 1 ? endDate.year - 1 : endDate.year,
                  endDate.month == 1 ? 12 : endDate.month - 1,
                  _safeDay(endDate),
                );
                _onBtnPushedChanged(1);
                break;

              case '3개월':
                whichButtonPush[2] = true;
                startDate = DateTime(
                  endDate.month <= 3 ? endDate.year - 1 : endDate.year,
                  endDate.month <= 3 ? endDate.month + 9 : endDate.month - 3,
                  _safeDay(endDate),
                );
                _onBtnPushedChanged(2);
                break;

              case '1년':
                whichButtonPush[3] = true;
                startDate = DateTime(endDate.year - 1, endDate.month, _safeDay(endDate));
                _onBtnPushedChanged(3);
                break;
            }
            _onDateRangeChanged(startDate, endDate);
           },);
        },
      ),
    );
  }

  int _safeDay(DateTime baseDate) {
    final year = baseDate.year;
    final month = baseDate.month;
    final lastDayOfPrevMonth = DateTime(year, month, 0).day;
    return baseDate.day > lastDayOfPrevMonth ? lastDayOfPrevMonth : baseDate.day;
  }


  Text waveText() {
    return Text(
      '~',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14 * wtio,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: -0.28 * wtio,
      ),
    );
  }

}

