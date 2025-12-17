part of '../../main.dart';

late TutorialCoachMark tutorialCoachMark;

// 네비게이션 바 튜토리얼
GlobalKey docTabBtn = GlobalKey();
GlobalKey stcTabBtn = GlobalKey();
GlobalKey cmuTabBtn = GlobalKey();
GlobalKey usrTabBtn = GlobalKey();
// 상단탭 튜토리얼
GlobalKey docBodyTabBtn = GlobalKey();
GlobalKey docDietTabBtn = GlobalKey();
// 기록>체중 튜토리얼
GlobalKey calendarItemKey = GlobalKey();

void createTutorial() {
  tutorialCoachMark = TutorialCoachMark(
    targets: _createTargets(),
    colorShadow: Colors.red,
    textSkip: "SKIP",
    paddingFocus: 15,
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
      identify: "docTabBtn",
      keyTarget: docTabBtn,
      alignSkip: Alignment.topRight,
      enableOverlayTab: true,
      enableTargetTab: false,
      unFocusAnimationDuration: const Duration(milliseconds: 0),
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "기록탭",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "체중, 식단을 기록하고 관리하는 화면이에요.",
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
      identify: "stcTabBtn",
      keyTarget: stcTabBtn,
      alignSkip: Alignment.topRight,
      enableOverlayTab: true,
      enableTargetTab: false,
      focusAnimationDuration: const Duration(milliseconds: 0),
      unFocusAnimationDuration: const Duration(milliseconds: 0),
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "통계탭",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "기록탭에서 기록한 데이터들을 시각화해서 보여주는 화면이에요.",
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
      identify: "cmuTabBtn",
      keyTarget: cmuTabBtn,
      alignSkip: Alignment.topRight,
      enableOverlayTab: true,
      enableTargetTab: false,
      focusAnimationDuration: const Duration(milliseconds: 0),
      unFocusAnimationDuration: const Duration(milliseconds: 0),
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "커뮤탭",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "다른 유저들과 소통하는 공간이에요.\n다양한 활동을 피드로 공유하고 정보를 얻을 수 있어요.",
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
      identify: "usrTabBtn",
      keyTarget: usrTabBtn,
      alignSkip: Alignment.topRight,
      enableOverlayTab: true,
      enableTargetTab: false,
      focusAnimationDuration: const Duration(milliseconds: 0),
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "유저탭",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "데이터백업 등 유저 맞춤 기능을 제공하는 공간이에요.",
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
      identify: "docBodyTabBtn",
      keyTarget: docBodyTabBtn,
      alignSkip: Alignment.bottomLeft,
      enableOverlayTab: true,
      enableTargetTab: false,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "기록탭 > 체중 기록 탭",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "체중 등 체성분을 기록하고 관리할 수 있어요.\n전체 기록은 달력으로 한눈에 파악할 수 있게 보여줘요.",
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
      identify: "docDietTabBtn",
      keyTarget: docDietTabBtn,
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      enableTargetTab: false,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder:(context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "기록탭 > 식단 기록 탭",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "하루 중 먹었던 음식을 기록하고 관리할 수 있어요\n기록한 식단의 전체 칼로리와 단백질(g)은 체중 기록 탭에서도 볼 수 있어요.",
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
  targets.add(TargetFocus(
      identify: "calendarItem",
      keyTarget: calendarItemKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  'assets/image/calendar_item_example.svg',
                  height: 48,
                ),
              ),
              const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "캘린더 셀",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                  Text(
                    "달력에서 날짜마다 입력한 체중, 총섭취칼로리, 하루평가를 보여줘요.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      shape: ShapeLightFocus.Circle,
    ));
  return targets;
}