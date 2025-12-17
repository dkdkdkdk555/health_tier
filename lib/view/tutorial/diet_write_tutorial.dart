part of '../../view/tab/doc/diet/doc_diet_write.dart';

late TutorialCoachMark tutorialCoachMarkDietWrite;

GlobalKey aiAnalyzeBtn = GlobalKey();

Future<void> createTutorial() async {
  tutorialCoachMarkDietWrite = TutorialCoachMark(
    targets: _createTargets(),
    colorShadow: Colors.red,
    textSkip: "SKIP",
    paddingFocus: 0,
    opacityShadow: 0.5,
    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
    onFinish: () {
    },
    onClickTarget: (target) {
    },
    onClickTargetWithTapPosition: (target, tapDetails) {
    },
    onClickOverlay: (target) {
    },
    onSkip: () {
      return true;
    },
  );
}

List<TargetFocus> _createTargets(){
  List<TargetFocus> targets = [];
  targets.add(
    TargetFocus(
      identify: "aiAnalyzeBtn",
      keyTarget: aiAnalyzeBtn,
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "AI 식단 분석",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    "AI에게 사진을 주면 영양성분을 분석하고 자동으로 입력해줘요",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        )
      ]
    )
  );
  return targets;
}