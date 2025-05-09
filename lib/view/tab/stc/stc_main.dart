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

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  List<bool> whichButtonPush = [true, false, false, false]; // 기간조회버튼 4가지의 

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    final param = DayRange(
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate),
    );

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (!sizingInformation.isMobile) return const Scaffold();

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
                  datePicker(context, pickedDay: startDate, isStart: true),
                  SizedBox(width: 8 * wtio),
                  waveText(),
                  SizedBox(width: 8 * wtio),
                  // 종료일
                  datePicker(context, pickedDay: endDate, isStart: false)
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
        onTap: () async{
          final picked = await showDayPicker(context, pickedDay);
          if (picked != null) {
            //TODO: startDate가 endDate보다 미래면 경고창 띄우며 검색시도하지 않기
            setState(() {
              if(isStart) {
                startDate = picked;
              } else {
                endDate = picked;
              }
            });
          }
        },
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
                periods('7일', whichButtonPush[0]),
                periods('1개월', whichButtonPush[1]),
                periods('3개월', whichButtonPush[2]),
                periods('1년', whichButtonPush[3]),
            ],
        ),
      ),
    );
  }

  Expanded periods(String text, bool isChoose) {
    var selectedColor = _selectedIndex == 0 ? const Color(0xFF0D86E7)
                        : _selectedIndex == 1 ? const Color(0xFF95D33E) 
                        : _selectedIndex == 2 ? const Color(0xFFFFDE23)
                        : const Color(0xFF000000);
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
                break;

              case '1개월':
                whichButtonPush[1] = true;
                startDate = DateTime(
                  endDate.month == 1 ? endDate.year - 1 : endDate.year,
                  endDate.month == 1 ? 12 : endDate.month - 1,
                  _safeDay(endDate),
                );
                break;

              case '3개월':
                whichButtonPush[2] = true;
                startDate = DateTime(
                  endDate.month <= 3 ? endDate.year - 1 : endDate.year,
                  endDate.month <= 3 ? endDate.month + 9 : endDate.month - 3,
                  _safeDay(endDate),
                );
                break;

              case '1년':
                whichButtonPush[3] = true;
                startDate = DateTime(endDate.year - 1, endDate.month, _safeDay(endDate));
                break;
            }
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

