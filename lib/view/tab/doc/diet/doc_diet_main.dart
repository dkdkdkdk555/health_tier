import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/view/tab/doc/diet/doc_calendar_diet.dart';
import 'package:my_app/view/tab/doc/diet/doc_diet_detail.dart';

class DocDietMain extends ConsumerStatefulWidget {
  const DocDietMain({super.key});

  @override
  ConsumerState<DocDietMain> createState() => _DocDietMainStateState();
}

class _DocDietMainStateState extends ConsumerState<DocDietMain> {
  final DateTime _focusedDay = DateTime.now();
  
  double _dragDistance = 0;
  double _bodyHeightFactor = 0.5099; // 35% → 65%까지 확장
  final double _minHeightFactor = 0.5099;
  final double _maxHeightFactor = 0.75;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final bodyHeight = screenHeight * _bodyHeightFactor;
    final bottomHeight = bodyHeight - (screenHeight * 0.5099);


    return Stack(
      children: [
        const Column(
          children: [
            Spacer(flex: 4,),
            DocCalendarDiet(),
            Spacer(flex: 10,),
            Expanded(flex: 207, child: SizedBox.shrink())
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
                // _showFullModal();
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

  // void _showFullModal() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     barrierColor: Colors.black.withAlpha(127),
  //     builder: (_) {
  //       return FractionallySizedBox(
  //         heightFactor: 0.92,
  //         child: DocBodyWrite(focusDay: _focusedDay, onSaved: _onDocSaved,)
  //       );
  //     },
  //   );
  // }
}