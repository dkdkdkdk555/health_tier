part of 'main.dart';

// 네비게이션바 숨김여부 프로바이더
final navigationBarHideProvider = StateProvider<bool>((ref) => false);

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/doc',
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
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: FeedDetail(
                    feedId: feedId,
                    categoryId: categoryId,
                    isFromWriteFeed: isFromWriteFeed,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // 오른쪽에서 시작
                    const end = Offset.zero;        // 현재 위치로 이동
                    const curve = Curves.ease;

                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
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
                return const UsrInfoScreen();
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
          ]
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
    final selectedIndex = _calculateIndex(GoRouterState.of(context));
    final navigationBarHide = ref.watch(navigationBarHideProvider);

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
              height: wtio * 0.14,
              width: wtio * 0.14,
              right: 38,
              bottom: 42,
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
                          showAppMessage(
                            context,
                            title: '로그인이 필요해요',
                            message:
                                '로그인이 필요한 기능입니다. 로그인 후 이용해주세요.',
                            type: AppMessageType.dialog,
                            loginRequest: true,
                          );
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
              margin: const EdgeInsets.only(bottom: 42),
              height: wtio * 0.14,
              width: wtio * 0.624,
              child: IslandNavigationBar(
                selectedIndex: selectedIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      context.go('/doc');
                      ref.read(currentPageProvider.notifier).state = 0;
                      break;
                    case 1:
                      context.go('/stc');
                      ref.read(currentPageProvider.notifier).state = 1;
                      break;
                    case 2:
                      context.go('/cmu');
                      ref.read(currentPageProvider.notifier).state = 2;
                      break;
                    case 3:
                      context.go('/usr');
                      ref.read(currentPageProvider.notifier).state = 3;
                      break;
                  }
                },
                wtio: wtio,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

