import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/main.dart' show navigationBarHideProvider;
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_body.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_header.dart';
import 'package:my_app/view/tab/doc/body/doc_body_detail.dart' show DocBodyDetail;
import 'package:my_app/view/tab/doc/body/doc_body_write.dart';
import 'package:my_app/extension/stc_invalidate_collect.dart';
import 'package:my_app/util/screen_ratio.dart';

class DocCalendarBody extends ConsumerStatefulWidget {
  const DocCalendarBody({super.key});

  @override
  ConsumerState<DocCalendarBody> createState() => _DocCalendarBodyState();
}

class _DocCalendarBodyState extends ConsumerState<DocCalendarBody> {
  DateTime _focusedDay = DateTime.now();

  double _dragDistance = 0;

  double _bodyHeightSize = 296; // 기본값 = 최소값
  final double _minHeightSize = 296; // 바텀영역 최소값
  final double _maxHeightSize = 543; // 바텀영역 최댓감

  void _goToPreviousMonth({DateTime? selectedDay}) {
    if(selectedDay == null && _focusedDay.isBefore(DateTime.utc(2022, 1, 1))){
      showAppDialog(context, message: '2022년 1월 1일 부터\n조회 가능합니다.', confirmText: '확인');
      return;
    }
    setState(() {
      _focusedDay = selectedDay ?? DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _goToNextMonth({DateTime? selectedDay}) {
    setState(() {
      _focusedDay = selectedDay ?? DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  void _goFocusedDay({required DateTime selectedDay}) {
    setState(() {
      _focusedDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ratio = ScreenRatio(context);
    final heightRatio = ratio.heightRatio;

    final bodyHeight = _bodyHeightSize * heightRatio;
    final bottomHeight = bodyHeight - (_minHeightSize * heightRatio);

    return Stack(
      children: [
        // 배경: Calendar 헤더 + 바디
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [ 
            SizedBox(
              height: 402 * heightRatio,
              child: Column(
                children: [
                  CustomCalendarHeader(
                    focusedDay: _focusedDay,
                    onLeftArrow: _goToPreviousMonth,
                    onRightArrow: _goToNextMonth,
                  ),
                  CustomCalenderBody(
                    focusedDay: _focusedDay,
                    onGoToNextMonth: _goToNextMonth,
                    onGoToPreviousMonth: _goToPreviousMonth,
                    onGoToFocusedDay: _goFocusedDay,
                    ratio: ratio,
                  ),
                ],
              ),
            ),
            SizedBox(child: SizedBox(height: 296 * heightRatio,)),
          ],
        ),

        // 위에 겹치는 DocBodyDetail (애니메이션으로 위로 확장됨)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          bottom: 0,
          left: 0,
          right: 0,
          height: bodyHeight,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragDistance += details.primaryDelta!;
                final expandedHeightSize = _minHeightSize - _dragDistance;
                _bodyHeightSize = expandedHeightSize.clamp(_minHeightSize, _maxHeightSize);
              });
            },
            onVerticalDragEnd: (_) {
              if (_bodyHeightSize >= 510) {
                _showFullModal();
              }
              setState(() {
                _bodyHeightSize = _minHeightSize;
                _dragDistance = 0;
              });
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(), 
                  child: DocBodyDetail(
                    focusedDay: _focusedDay,
                    bottomHeight: bottomHeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }



  void _showFullModal() async{
    ref.read(navigationBarHideProvider.notifier).state = true;
    final ratio = ScreenRatio(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(127),
      constraints: BoxConstraints(
        maxHeight: ScreenRatio.baseHeight * ratio.heightRatio * 0.92,
        maxWidth: ScreenRatio.baseWidth * ratio.widthRatio,
      ),
      builder: (_) => DocBodyWrite(
        focusDay: _focusedDay,
        onSaved: _onDocSaved,
      ),
    );

    ref.read(navigationBarHideProvider.notifier).state = false;
  }

  void _onDocSaved() {
    final refreshDay = DateFormat('yyyy-MM-dd').format(_focusedDay);
    final refreshMonth = DateFormat('yyyy-MM').format(_focusedDay);
    ref.invalidate(htDayDocDetail(refreshDay));
    ref.invalidate(htDayDocOfMonth(refreshMonth));
    ref.invalidate(selectHtDayDoc(refreshDay));
    ref.invalidate(getPreviousWeight(refreshDay));
    ref.invalidate(getLatestWeightProvider);
    StcInvalidator().stcInvalidate(ref);
  }
}


