import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/view/tab/doc/diet/doc_calendar_diet.dart';
import 'package:my_app/view/tab/doc/diet/doc_diet_detail.dart';
import 'package:my_app/view/tab/doc/diet/doc_diet_write.dart';

class DocDietMain extends ConsumerStatefulWidget {
  const DocDietMain({super.key});

  @override
  ConsumerState<DocDietMain> createState() => _DocDietMainStateState();
}

class _DocDietMainStateState extends ConsumerState<DocDietMain> {
  DateTime _focusedDay = DateTime.now();
  
  double _dragDistance = 0;
  double _bodyHeightFactor = 0.5099; // 35% → 65%까지 확장
  final double _minHeightFactor = 0.5099;
  final double _maxHeightFactor = 0.75;

  void _goFocusedDay({required DateTime selectedDay}) {
    setState(() {
      _focusedDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final bodyHeight = screenHeight * _bodyHeightFactor;
    final bottomHeight = bodyHeight - (screenHeight * 0.5099);


    return Stack(
      children: [
        Column(
          children: [
            const Spacer(flex: 4,),
            DocCalendarDiet(focusedDay: _focusedDay, onGoToFocusedDay: _goFocusedDay, ),
            const Spacer(flex: 10,),
            const Expanded(flex: 207, child: SizedBox.shrink())
          ],
        ),

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
              if (_bodyHeightFactor >= 0.70) {
                _showFullModal();
              }
              setState(() {
                _bodyHeightFactor = _minHeightFactor;
                _dragDistance = 0;
              });
            },
            child: DocDietDetail(focusedDay: _focusedDay, bottomHeight: bottomHeight,),
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
          child: DocDietWrite(focusDay: _focusedDay, onSaved: _onDocSaved,)
        );
      },
    );
  }

  void _onDocSaved() {
    // final refreshDay = DateFormat('yyyy-MM-dd').format(_focusedDay);
    // final refreshMonth = DateFormat('yyyy-MM').format(_focusedDay);
    // ref.invalidate(htDayDocDetail(refreshDay));
    // ref.invalidate(htDayDocOfMonth(refreshMonth));
    // ref.invalidate(selectHtDayDoc(refreshDay));
  }
}