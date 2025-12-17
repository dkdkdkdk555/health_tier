part of '../../view/tab/doc/diet/doc_diet_main.dart';

late TutorialCoachMark tutorialCoachMarkDiet;

GlobalKey dietCalendar = GlobalKey();
GlobalKey dietCalendarHeader = GlobalKey();
GlobalKey totalKcalAndProtien = GlobalKey();
GlobalKey aiAnalyzeBtn = GlobalKey();

Future<void> createTutorial() async {
  tutorialCoachMarkDiet = TutorialCoachMark(
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
      identify: "dietCalendar",
      keyTarget: dietCalendar,
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "좌우로 스크롤해서 날짜를 이동할 수 있어요.",
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
  targets.add(
    TargetFocus(
      identify: "dietCalendarHeader",
      keyTarget: dietCalendarHeader,
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "클릭하면 캘린더 팝업이 나와요. 날짜를 클릭하면 한번에 이동할 수 있어요",
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
  targets.add(
    TargetFocus(
      identify: "totalKcalAndProtien",
      keyTarget: totalKcalAndProtien,
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "하루에 입력한 총 칼로리와 단백질을 자동으로 계산해서 표시해요",
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