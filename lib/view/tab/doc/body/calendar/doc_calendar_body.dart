import 'package:flutter/material.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_body.dart';
import 'package:my_app/view/tab/doc/body/calendar/calendar_header.dart';
import 'package:my_app/view/tab/doc/body/doc_body_detail.dart' show DocBodyDetail;
import 'package:my_app/view/tab/doc/body/doc_body_write.dart';

class DocCalendarBody extends StatefulWidget {
  const DocCalendarBody({super.key});

  @override
  State<DocCalendarBody> createState() => _DocCalendarBodyState();
}

class _DocCalendarBodyState extends State<DocCalendarBody> {
  DateTime _focusedDay = DateTime.now();

  double _dragDistance = 0;
  double _bodyHeightFactor = 0.36453202; // 35% → 65%까지 확장
  final double _minHeightFactor = 0.36453202;
  final double _maxHeightFactor = 0.65;

  void _goToPreviousMonth({DateTime? selectedDay}) {
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
    final screenHeight = MediaQuery.of(context).size.height;

    final bodyHeight = screenHeight * _bodyHeightFactor;
    final bottomHeight = bodyHeight - (screenHeight * 0.36453202);

    return Stack(
      children: [
        // 배경: Calendar 헤더 + 바디
        Column(
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
                  CustomCalenderBody(
                    focusedDay: _focusedDay,
                    onGoToNextMonth: _goToNextMonth,
                    onGoToPreviousMonth: _goToPreviousMonth,
                    onGoToFocusedDay: _goFocusedDay,
                  ),
                ],
              ),
            ),
            const Expanded(flex: 148, child: SizedBox.shrink()),
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
                final expandedRatio = _minHeightFactor - (_dragDistance / screenHeight);
                _bodyHeightFactor = expandedRatio.clamp(_minHeightFactor, _maxHeightFactor);
              });
            },
            onVerticalDragEnd: (_) {
              if (_bodyHeightFactor >= 0.60) {
                _showFullModal();
              }
              setState(() {
                _bodyHeightFactor = _minHeightFactor;
                _dragDistance = 0;
              });
            },
            child: DocBodyDetail(focusedDay: _focusedDay, bottomHeight: bottomHeight,),
          ),
        ),
      ],
    );
  }



  void _showFullModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(127),
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: DocBodyWrite(focusDay: _focusedDay,)
        );
      },
    );
  }
}


