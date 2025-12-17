part of '../../view/tab/doc/diet/doc_diet_write.dart';

late TutorialCoachMark tutorialCoachMarkDietWrite;

final GlobalKey aiAnalyzeBtn = GlobalKey();

Future<void> createTutorial() async {
  tutorialCoachMarkDietWrite = TutorialCoachMark(
    targets: _createTargets(),
    colorShadow: Colors.black,
    paddingFocus: 0,
    opacityShadow: 0.5,
    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
    textSkip: 'SKIP',
    onSkip: () => true,
  );
}

List<TargetFocus> _createTargets() {
  return [
    buildTarget(
      id: 'aiAnalyzeBtn',
      key: aiAnalyzeBtn,
      align: ContentAlign.bottom,
      builder: (_, __) => titleDescContent(
        title: 'AI 식단 분석',
        description: 'AI에게 사진을 주면 영양성분을 분석하고 자동으로 입력해줘요.',
      ),
    ),
  ];
}
