part of 'main.dart';

// 네비게이션바 숨김여부 프로바이더
final navigationBarHideProvider = StateProvider<bool>((ref) => false);

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/doc',
  // info.plist 설정을 FlutterDeepLinkingEnabled 하므로서 카카오톡으로 로그인하는 경우
  // go_router 패키지와 더불어 나타나는 리다이렉트 문제를 임시방편으로 막아둠.
  // redirect: (context, state) {
  //   final uri = Uri.tryParse(state.uri.toString());
  //   if (uri != null && uri.scheme.startsWith('kakao')) {
  //     debugPrint('외부 카카오 URL 무시: ${state.uri.toString()}');
  //     return '/usr'; // 카카오톡으로 로그인하는 경우 자꾸 응답링크로 리다이렉트 시키려고함, 
  //     // return null 이나 '' 해도 응답링크로 보내짐, 
  //   }
  //   return null; --> 딥링크 구현 시 AppLink 패키지를 사용해서 이 문제는 해결,, 여전히 FlutterDeepLinkingEnabled 는 false임
  // },
  redirect: (context, state) {
    final fullUri = state.uri; // GoRouter가 받은 전체 URI (healthtierscheme://cmu/feed/10)
    
    // 딥링크 스킴인지 확인
    if (fullUri.scheme == 'healthtierscheme' && fullUri.host == 'cmu') {
        // 경로 세그먼트에서 피드 ID를 추출하여 내부 경로로 변환
        final feedIdString = fullUri.pathSegments.lastWhere((s) => RegExp(r'^\d+$').hasMatch(s), orElse: () => '');
        
        if (feedIdString.isNotEmpty) {
            final targetPath = '/cmu/feed/$feedIdString';
            return targetPath; // 내부 경로(/cmu/feed/10)로 리다이렉션
        }
    }
    return null; // 리다이렉션 없음
  },
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return _ShellScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/doc', 
          builder: (context, state) => const DocMain(),
        ),
        GoRoute(path: '/stc', 
          builder: (context, state) => const StcMain()
        ),
        GoRoute(path: '/cmu', 
          builder: (context, state) => const CmuMain(),
          routes: [
            GoRoute( // 사용자 프로필 화면
              path: 'profile/:userId',
              builder: (context, state) {
                final userId = int.parse(state.pathParameters['userId']!);
                return CmuUsrProfile(userId: userId);
              },
              parentNavigatorKey: rootNavigatorKey,
            ),
            GoRoute( // 통합검색 화면
              path: 'srch',
              builder: (context, state) {
                return const CmuTotalSrch();
              },
              parentNavigatorKey: rootNavigatorKey,
            ),
            GoRoute(
              path: 'feed/:feedId',
              pageBuilder: (context, state) {
                final feedId = int.parse(state.pathParameters['feedId']!);
                final categoryId = state.uri.queryParameters['categoryId'] != null
                    ? int.tryParse(state.uri.queryParameters['categoryId']!)
                    : null;

                final isFromWriteFeed = state.uri.queryParameters['isFromWriteFeed'] == 'true';
                final isFromNotifi = state.uri.queryParameters['isFromNotifi'] == 'true';

                return CupertinoPage(
                  key: state.pageKey,
                  child: FeedDetail(
                    feedId: feedId,
                    categoryId: categoryId,
                    isFromWriteFeed: isFromWriteFeed,
                    isFromNotifi: isFromNotifi,
                  ),
                );
              },
              parentNavigatorKey: rootNavigatorKey,
            ),
            GoRoute( // 피드 수정
              path: 'writeFeed',
              builder: (context, state) {
                final feedId = state.extra as int?;
                return WriteFeed(feedId: feedId);
              },
              parentNavigatorKey: rootNavigatorKey,
            ),
          ]
        ),
        GoRoute(path: '/usr', 
          builder: (context, state) => const UsrMain(),
          routes: [
            GoRoute( // 마이페이지
              path: 'info',
              builder: (context, state) {
                final isFromNotifi = state.uri.queryParameters['isFromNotifi'] == 'true';
                return UsrInfoScreen(
                  isFromNotifi: isFromNotifi,
                );
              },
              routes: [
                GoRoute( // 내 정보 관리
                  path: 'management',
                  builder: (context, state) {
                    return const UsrInfoManagement();
                  },
                  parentNavigatorKey: rootNavigatorKey,
                  routes: [
                    GoRoute( // 알림목록 조회
                      path: 'notifications',
                      builder: (context, state) {
                        return const NotificationManagePage();
                      },
                      parentNavigatorKey: rootNavigatorKey,
                    ),
                    GoRoute( // 회원탈퇴 페이지
                      path: 'signout',
                      builder: (context, state) {
                        return const UsrSignoutNoticePage();
                      },
                      parentNavigatorKey: rootNavigatorKey,
                    ),
                    GoRoute( // 차단사용자 조회
                      path: 'blockusers',
                      builder: (context, state) {
                        return const BlockManagePage();
                      },
                      parentNavigatorKey: rootNavigatorKey,
                    ),
                  ]
                ),
              ]
            ),
            GoRoute( // 닉네임 입력 페이지
              path: 'nicknameInput',
              builder: (context, state) => const NicknameInputPage(),
              parentNavigatorKey: rootNavigatorKey,
            ),
            GoRoute( // 시작하기 화면
              path: 'login',
              builder: (context, state) {
                return const GetStartedScreen();
              },
              parentNavigatorKey: _shellNavigatorKey,
            ),
            GoRoute( // 이용약관, 개인정보처리방침 웹뷰 페이지
              path: 'agremment',
              builder: (context, state) {
                final title = state.uri.queryParameters['title']!;
                final url = state.uri.queryParameters['url']!;
                return WebViewPage(title: title, url: url);
              },
              parentNavigatorKey: rootNavigatorKey,
            ),
            GoRoute( // 관리자 페이지
              path: 'admin',
              builder: (context, state) {
                return const AdminManagePage();
              },
              parentNavigatorKey: rootNavigatorKey,
              routes: [
                GoRoute( // 피드 신고관리
                  path: 'manage/feed',
                  builder: (context, state) {
                    return const AdminManageList(topic: 'feed',);
                  },
                  parentNavigatorKey: rootNavigatorKey,
                ),
                GoRoute( // 댓글 신고관리
                  path: 'manage/reply',
                  builder: (context, state) {
                    return const AdminManageList(topic: 'reply',);
                  },
                  parentNavigatorKey: rootNavigatorKey,
                ),
              ]
            ),
          ]
        ),
        // 카카오 연동 회원가입 시 /oauth가 요청되는 현상때문에 임시 조치
        GoRoute(
          path: '/oauth',
          redirect: (_, __) => '/usr',
        ),
      ],
    ),
  ],
);

class _ShellScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const _ShellScaffold({required this.child, super.key});

  @override
  ConsumerState<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<_ShellScaffold> with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<Offset> _fabSlide;
  late Animation<double> _fabOpacity;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fabSlide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut));

    _fabOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeIn),
    );
    Future.delayed(const Duration(milliseconds: 2400), showTutorial);
  }

  void showTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final isShown = prefs.getBool("is_main_tutorial_shown") ?? false;
    if(!isShown) {
      if(!mounted)return;
      tutorialCoachMark.show(context: context);
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  int _calculateIndex(GoRouterState state) {
    final path = state.uri.path;
    if (path.startsWith('/doc')) return 0;
    if (path.startsWith('/stc')) return 1;
    if (path.startsWith('/cmu')) return 2;
    if (path.startsWith('/usr')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final wtio = MediaQuery.of(context).size.width;
    final htio = MediaQuery.of(context).size.height;

    // 튜토리얼 트리거 감시
    ref.listen(dietTutorialTriggerProvider, (previous, next) {
      if (next != null) {
        // 여기서 show를 호출하면 _ShellScaffold의 context를 사용하므로 
        // 하위의 네비게이션 바까지 모두 포함하여 블러 처리가 됩니다.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 300));
          if(!context.mounted) return;
          tutorialCoachMarkDiet.show(context: context);
        });
      }
    });
    
    final selectedIndex = _calculateIndex(GoRouterState.of(context));
    final navigationBarHide = ref.watch(navigationBarHideProvider);

    // 최대 크기 제한 적용
    const double maxNavWidth = 420.0;
    final double navWidth = math.min(wtio * 0.624, maxNavWidth);
    // FAB 크기 (비율 + 상한)
    final double fabSize = math.min(wtio * 0.14, 90.0);
    // FAB와 NavigationBar 사이 간격 (비율 유지)
    double bottomMargin = math.min(42.0, wtio * 0.11);

    final isWide = wtio > 600;
    final double ratio = ScreenRatio(context).widthRatio;
    final double rightPosition = isWide ? 140 : 42 * ratio;

    if (selectedIndex == 2) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: navigationBarHide ? null : Stack(
        alignment: Alignment.center,
        children: [
          if (selectedIndex == 2)
            Positioned(
              height: fabSize,
              width: fabSize,
              right: rightPosition,
              bottom: bottomMargin,
              child: SlideTransition(
                position: _fabSlide,
                child: FadeTransition(
                  opacity: _fabOpacity,
                  child: FloatingActionButton(
                    onPressed: () async {
                      try {
                        final response = await ref.read(jwtTokenVerificationProvider.future);
                        if (response.isValid) {
                          if (!context.mounted) return;
                          context.push('/cmu/writeFeed'); // GoRouter로 이동
                        } else {
                          if (!context.mounted) return;
                        }
                      } catch (e) {
                        showAppMessage(
                          context,
                          message:
                              '서버 오류가 발생하였습니다.\n반복될 경우 관리자에게 문의하세요.',
                          type: AppMessageType.dialog,
                        );
                        debugPrint('$e');
                      }
                    },
                    backgroundColor: const Color(0xFF0D85E7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        SvgPicture.asset('assets/widgets/create_feed.svg'),
                  ),
                ),
              ),
            ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            alignment: selectedIndex == 2
                ? const Alignment(-0.45, 1.0)
                : Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: bottomMargin),
              height: fabSize,
              width: navWidth,
              child: IslandNavigationBar(
                selectedIndex: selectedIndex,
                onTap: (index) {
                  switch (index){
                    case 0:
                      ref.read(currentPageProvider.notifier).state = 0;
                      context.go('/doc');
                      break;
                    case 1:
                      ref.read(currentPageProvider.notifier).state = 1;
                      context.go('/stc');
                      break;
                    case 2:
                      ref.read(currentPageProvider.notifier).state = 2;
                      context.go('/cmu');
                      break;
                    case 3:
                      ref.read(currentPageProvider.notifier).state = 3;
                      context.go('/usr');
                      break;
                  }
                },
                wtio: wtio,
                htio: htio,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

