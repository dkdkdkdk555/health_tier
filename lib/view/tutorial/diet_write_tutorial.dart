part of '../../view/tab/doc/diet/doc_diet_write.dart';

late TutorialCoachMark tutorialCoachMarkDietWrite;

final GlobalKey aiAnalyzeBtn = GlobalKey();

Future<void> createTutorial({
  required WidgetRef ref,
  required double wtio,
  required double htio,
}) async {
  tutorialCoachMarkDietWrite = TutorialCoachMark(
    targets: _createTargets(wtio: wtio, htio: htio),
    colorShadow: Colors.black,
    paddingFocus: 0,
    opacityShadow: 0.5,
    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
    textSkip: 'SKIP',
    onSkip: () {
      ref.read(dietWriteTutorialStorageProvider.notifier).markAsShown();
      return true;
    },
    onFinish: () {
      ref.read(dietWriteTutorialStorageProvider.notifier).markAsShown();
    },
  );
}

List<TargetFocus> _createTargets({
  required double wtio,
  required double htio,
}) {
  return [
    buildTarget(
      id: 'aiAnalyzeBtn',
      key: aiAnalyzeBtn,
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      builder: (_, __) => titleDescContent(
        title: 'AI 식단 분석',
        description: 'AI에게 사진을 주면 영양성분을 분석하고\n자동으로 입력해 줘요.',
        htio: htio,
        wtio: wtio,
      ),
    ),
  ];
}
