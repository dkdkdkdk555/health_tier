part of '../../main.dart';

late TutorialCoachMark tutorialCoachMark;

// 네비게이션 바
final GlobalKey docTabBtn = GlobalKey();
final GlobalKey stcTabBtn = GlobalKey();
final GlobalKey cmuTabBtn = GlobalKey();
final GlobalKey usrTabBtn = GlobalKey();
// 상단 탭
final GlobalKey docBodyTabBtn = GlobalKey();
final GlobalKey docDietTabBtn = GlobalKey();
// 기록 > 체중
final GlobalKey calendarItemKey = GlobalKey();
// 상세 영역
final GlobalKey weightTextKey = GlobalKey();
final GlobalKey proteinTextKey = GlobalKey();
final GlobalKey kcalTextKey = GlobalKey();
final GlobalKey bottomBarHandleKey = GlobalKey();


void createTutorial() {
  tutorialCoachMark = TutorialCoachMark(
    targets: _createTargets(),
    colorShadow: Colors.black,
    opacityShadow: 0.5,
    paddingFocus: 10,
    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
    textSkip: 'SKIP',
    onSkip: () => true,
  );
}

List<TargetFocus> _createTargets() {
  return [
    // 기록탭
    buildTarget(
      id: 'docTabBtn',
      key: docTabBtn,
      align: ContentAlign.top,
      unFocusDuration: const Duration(milliseconds: 0),
      builder: (_, __) => titleDescContent(
        title: '기록탭',
        description: '체중, 식단을 기록하고 관리하는 화면이에요.',
      ),
    ),

    // 통계탭
    buildTarget(
      id: 'stcTabBtn',
      key: stcTabBtn,
      align: ContentAlign.top,
      focusDuration: const Duration(milliseconds: 0),
      unFocusDuration: const Duration(milliseconds: 0),
      builder: (_, __) => titleDescContent(
        title: '통계탭',
        description: '기록탭에서 기록한 데이터들을 시각화해서 보여주는 화면이에요.',
      ),
    ),

    // 커뮤니티탭
    buildTarget(
      id: 'cmuTabBtn',
      key: cmuTabBtn,
      align: ContentAlign.top,
      focusDuration: const Duration(milliseconds: 0),
      unFocusDuration: const Duration(milliseconds: 0),
      builder: (_, __) => titleDescContent(
        title: '커뮤탭',
        description:
            '다른 유저들과 소통하는 공간이에요.\n다양한 활동을 피드로 공유하고 정보를 얻을 수 있어요.',
      ),
    ),

    // 유저탭
    buildTarget(
      id: 'usrTabBtn',
      key: usrTabBtn,
      align: ContentAlign.top,
      focusDuration: const Duration(milliseconds: 0),
      builder: (_, __) => titleDescContent(
        title: '유저탭',
        description: '데이터 백업 등 유저 맞춤 기능을 제공하는 공간이에요.',
      ),
    ),

    // 체중 기록 탭
    buildTarget(
      id: 'docBodyTabBtn',
      key: docBodyTabBtn,
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      builder: (_, __) => titleDescContent(
        title: '기록탭 > 체중 기록',
        description:
            '체중 등 체성분을 기록하고 관리할 수 있어요.\n전체 기록은 달력으로 한눈에 볼 수 있어요.',
      ),
    ),

    // 식단 기록 탭
    buildTarget(
      id: 'docDietTabBtn',
      key: docDietTabBtn,
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      builder: (_, __) => titleDescContent(
        title: '기록탭 > 식단 기록',
        description:
            '하루 중 먹은 음식을 기록할 수 있어요.\n총 칼로리와 단백질은 체중 탭에서도 확인 가능해요.',
      ),
    ),

    // 캘린더 셀 (특수)
    buildTarget(
      id: 'calendarItem',
      key: calendarItemKey,
      align: ContentAlign.bottom,
      alignSkip: Alignment.bottomRight,
      shape: ShapeLightFocus.Circle,
      builder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SvgPicture.asset(
                  'assets/image/calendar_item_example.svg',
                  height: 56,
                ),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '캘린더 셀',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '달력에서 날짜마다 입력한 체중, 총 섭취칼로리, 하루평가를 보여줘요.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),

    // 체중 입력
    buildTarget(
      id: 'weightTextKey',
      key: weightTextKey,
      align: ContentAlign.top,
      builder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Text(
            '영역을 위로 끌어올려 체중을 입력할 수 있어요.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),

    // 단백질
    buildTarget(
      id: 'proteinTextKey',
      key: proteinTextKey,
      align: ContentAlign.top,
      builder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Text(
            '식단탭에서 입력한 식사의 하루 총 단백질 섭취량을 보여줘요.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),

    // 칼로리
    buildTarget(
      id: 'kcalTextKey',
      key: kcalTextKey,
      align: ContentAlign.top,
      builder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            '식단탭에서 입력한 식사의\n하루 총 섭취 칼로리를 보여줘요.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),

    // 하단 핸들
    buildTarget(
      id: 'bottomBarHandleKey',
      key: bottomBarHandleKey,
      align: ContentAlign.top,
      builder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UpArrowIndicator(durationTime: 1000, color: Colors.white),
            SizedBox(height: 6),
            Text(
              '이제 위로 끌어올려 오늘의 평가와 체성분을 입력해보세요!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  ];
}
