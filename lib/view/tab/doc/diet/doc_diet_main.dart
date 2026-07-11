import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_app/main.dart' show navigationBarHideProvider;
import 'package:my_app/notifier/tutorial_notifier.dart' show dietTutorialStorageProvider, tutorialCoachMarkDiet;
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/doc/diet/doc_calendar_diet.dart';
import 'package:my_app/view/tab/doc/diet/doc_diet_detail.dart';
import 'package:my_app/view/tab/doc/diet/doc_diet_write.dart';
import 'package:my_app/view/tutorial/common_functions.dart' show buildTarget, titleDescContent;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

part '../../../tutorial/diet_tutorial.dart';

class DocDietMain extends ConsumerStatefulWidget {
  const DocDietMain({super.key, this.initialDay});

  /// 진입 시 포커스할 날짜 (미지정 시 오늘)
  final DateTime? initialDay;

  @override
  ConsumerState<DocDietMain> createState() => _DocDietMainState();
}

class _DocDietMainState extends ConsumerState<DocDietMain> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late DateTime _focusedDay;

  double _dragDistance = 0;
  double _bodyHeightSize = 414; // 기본값 = 최소값
  final double _minHeightSize = 414; // 바텀영역 최소값
  final double _maxHeightSize = 595; // 바텀영역 최댓감

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDay ?? DateTime.now();
  }

  void _goFocusedDay({required DateTime selectedDay}) {
    setState(() {
      _focusedDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final ratio = ScreenRatio(context);
    final heightRatio = ratio.heightRatio;

    final bodyHeight = _bodyHeightSize * heightRatio;
    final bottomHeight = bodyHeight - (_minHeightSize * heightRatio);

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 8 * heightRatio,),
            DocCalendarDiet(focusedDay: _focusedDay, onGoToFocusedDay: _goFocusedDay, ),
            SizedBox(height: 20 * heightRatio,),
            SizedBox(height: 414 * heightRatio,)
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
                final expandedHeightSize = _minHeightSize - _dragDistance;
                _bodyHeightSize = expandedHeightSize.clamp(_minHeightSize, _maxHeightSize);
              });
            },
            onVerticalDragEnd: (_) {
              if (_bodyHeightSize >= 460) {
                _showFullModal();
              }
              setState(() {
                _bodyHeightSize = _minHeightSize;
                _dragDistance = 0;
              });
            },
            child: DocDietDetail(focusedDay: _focusedDay, bottomHeight: bottomHeight,),
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
      builder: (_) => DocDietWrite(focusDay: _focusedDay, onSaved: _onDocSaved,)
    );

    ref.read(navigationBarHideProvider.notifier).state = false;
  }


  void _onDocSaved() {
    final refreshDay = DateFormat('yyyy-MM-dd').format(_focusedDay);
    final refreshMonth = DateFormat('yyyy-MM').format(_focusedDay);
    ref.invalidate(selectDietDocList(refreshDay));
    ref.invalidate(selectDayDietTotal(refreshDay));
    ref.invalidate(selectDietDayDoc(refreshDay));
    ref.invalidate(htDayDocDetail(refreshDay));
    ref.invalidate(htDayDocOfMonth(refreshMonth));
  }
}

/// go_router 로 진입하는 특정 날짜 식단 화면.
/// (예: 체중기록 화면의 '식단 기록' 버튼 → /doc/diet?day=yyyy-MM-dd)
class DocDietRoutePage extends StatelessWidget {
  const DocDietRoutePage({super.key, required this.focusedDay});

  final DateTime focusedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF333333)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '식단 기록',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 17,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: DocDietMain(initialDay: focusedDay),
    );
  }
}