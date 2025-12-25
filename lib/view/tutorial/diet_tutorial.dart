part of '../../view/tab/doc/diet/doc_diet_main.dart';

// 튜토리얼 실행 신호를 보내기 위한 프로바이더 (DateTime은 중복 클릭 시에도 반응하게 하기 위함) 
// 프로바이더는 값이 달라야지만 반응하기때문에 DateTime이 필요
final dietTutorialTriggerProvider = StateProvider<DateTime?>((ref) => null);

late TutorialCoachMark tutorialCoachMarkDiet;

final GlobalKey dietCalendar = GlobalKey();
final GlobalKey dietCalendarHeader = GlobalKey();
final GlobalKey totalKcalAndProtien = GlobalKey();
final GlobalKey aiAnalyzeBtn = GlobalKey();

Future<void> createTutorialDiet({
  required WidgetRef ref,
  required double wtio,
  required double htio,
}) async {
  tutorialCoachMarkDiet = TutorialCoachMark(
    targets: _createTargets(wtio: wtio, htio: htio),
    colorShadow: Colors.black,
    paddingFocus: 0,
    opacityShadow: 0.5,
    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
    skipWidget: Container(
      margin: EdgeInsets.symmetric(horizontal: 20*wtio),
      padding: EdgeInsets.symmetric(
        horizontal: 8 * htio,
        vertical: 4 * htio,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        'SKIP',
        style: TextStyle(
          fontSize: 14 * htio,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
    onSkip: () {
      ref.read(dietTutorialStorageProvider.notifier).markAsShown();
      return true;
    },
    onFinish: () {
      ref.read(dietTutorialStorageProvider.notifier).markAsShown();
    },
  );
}

List<TargetFocus> _createTargets({
  required double wtio,
  required double htio,
}) {
  return [
    // 식단 캘린더
    buildTarget(
      id: 'dietCalendar',
      key: dietCalendar,
      align: ContentAlign.bottom,
      shape: ShapeLightFocus.RRect,
      alignSkip: Alignment.bottomRight,
      builder: (_, __) => titleDescContent(
        title: '식단 캘린더',
        description: '좌우로 스크롤 해서 날짜를 이동할 수 있어요.',
        htio: htio,
        wtio: wtio,
      ),
    ),

    // 캘린더 헤더
    buildTarget(
      id: 'dietCalendarHeader',
      key: dietCalendarHeader,
      align: ContentAlign.bottom,
      shape: ShapeLightFocus.RRect,
      alignSkip: Alignment.bottomRight,
      builder: (_, __) => titleDescContent(
        title: '날짜 선택',
        description:
            '터치하면 캘린더 팝업이 나와요.\n원하는 날짜로 한 번에 이동할 수 있어요.',
        htio: htio,
        wtio: wtio,
      ),
    ),

    // 총 칼로리 / 단백질
    buildTarget(
      id: 'totalKcalAndProtien',
      key: totalKcalAndProtien,
      align: ContentAlign.bottom,
      shape: ShapeLightFocus.RRect,
      alignSkip: Alignment.bottomRight,
      builder: (_, __) => titleDescContent(
        title: '하루 섭취량 요약',
        description:
            '하루에 입력한 총 칼로리와 단백질을 자동으로 계산해서 표시해요.',
        htio: htio,
        wtio: wtio,
      ),
    ),
  ];
}
