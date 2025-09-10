part of 'main.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/doc',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return _ShellScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/doc', 
          builder: (context, state) => const DocMain()
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
              parentNavigatorKey: _rootNavigatorKey,
            )
          ]
        ),
        GoRoute(path: '/usr', 
          builder: (context, state) => const UsrMain()
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

    if (selectedIndex == 2) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: Stack(
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
                          context.push('/writeFeed'); // GoRouter로 이동
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
                      break;
                    case 1:
                      context.go('/stc');
                      break;
                    case 2:
                      context.go('/cmu');
                      break;
                    case 3:
                      context.go('/usr');
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

