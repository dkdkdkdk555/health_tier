import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/dialog_utils.dart' show showMediaPopup;
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/firebase_remote_config_service.dart' show RemoteConfigService;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/cmu/feed/list/cmu_category_top_bar_delegate.dart';
import 'package:my_app/view/tab/cmu/feed/list/cmu_feed_list_sliver.dart';
import 'package:my_app/view/tab/cmu/feed/list/cmu_new_feed_alarm.dart';
import 'package:my_app/view/tab/simple_cache.dart' show cachedCmuTabIndex;
import 'package:my_app/view/tab/cmu/feed/list/cmu_app_bar_delegate.dart';

class CmuMain extends ConsumerStatefulWidget {
  const CmuMain({super.key});

  @override
  ConsumerState<CmuMain> createState() => _CmuMainState();
}

 var htio = 0.0;

class _CmuMainState extends ConsumerState<CmuMain> with TickerProviderStateMixin {
  // 어느 하위 탭인지
  late int _selectedIndex;
  // 스크롤 상태관리
  late ScrollController _scrollController;
  bool _scrolledDown = false;
  // 카테고리바 펼쳐짐 여부
  bool isSpread = false;
  // 처음 화면 진입 상태관리
  bool _initialLoadDone = false;
  // 최신피드id
  int? latestFeedId;
  // 새게시글 위젯표시 변수
  OverlayEntry? _alarmOverlay;
  // 중복호출 방지 플래그
  bool _checkingNewFeed = false;
  // 카테고리 상태
  bool isBestFeedTap = false;
  int selectedCategoryId = 0; // '전체' 카테고리 기본 선택

  late String clickUrl;
  late String mediaUrl;
  late bool onAdCmu;

  // 카테고리 선택 콜백
  void _categoryChange({required int index}){
    selectedCategoryId = index;
    ref.read(feedParamsProvider.notifier).state = FeedQueryParams(
      categoryId: index,
      hotYn: isBestFeedTap ? 1 : 0,
      cursorId: null,
      limit: 10,
    );
  }

  void _getHotFeedBtnClick({required bool hotYn}){
    isBestFeedTap = hotYn;
    ref.read(feedParamsProvider.notifier).state = FeedQueryParams(
      categoryId: selectedCategoryId,
      hotYn: hotYn ? 1 : 0,
      cursorId: null,
      limit: 10,
    );
  }
  
  void _saveLatestIndex({required int index}){
    latestFeedId = index;
  }

  void toggleSpread() {
    setState(() {
      isSpread = !isSpread;
    });
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) { // 웹에서 접근 시 네비게이션 바 숨기기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationBarHideProvider.notifier).state = true;
      });
    }

    _selectedIndex = cachedCmuTabIndex; // 캐시된 값 불러오기

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // f1 : 스크롤 방향 감지
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        // 아래로 스크롤 시작
        if (!_scrolledDown) {
          setState(() {
            _scrolledDown = true;
          });
          if (_alarmOverlay != null) {
            _showNewFeedAlarmOverlay(); // 다시 띄워서 위치 갱신
          }
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        // 위로 스크롤 시작
        if (_scrolledDown) {
          setState(() {
            _scrolledDown = false;
          });
        }
        if (_alarmOverlay != null) {
          _showNewFeedAlarmOverlay(); // 다시 띄워서 위치 갱신
        }
      }

      // f2 : 무한스크롤 감지
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        // 거의 바닥 근처까지 스크롤됐을 때 다음 페이지 로드
        final params = ref.read(feedParamsProvider);
        ref.read(feedPaginationProvider(params).notifier).fetchNext();
      }

      // f3 : 새 피드 있는지 묻기
      if (_initialLoadDone && _scrollController.position.pixels <= 0) {
        _checkNewFeed();
      }

      // 최초 1회 로딩 후 true로 전환
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialLoadDone = true;
      });
    });

    _getRemoteConfigValue();
  }

  _getRemoteConfigValue() async {
    await Future.delayed(const Duration(milliseconds: 1000)); 
    await _getInstance();
  }

  Future<void> _getInstance() async {
    final shouldHideAd = await UserPrefs.shouldHideAdToday();
    if(shouldHideAd) return;
    final remoteConfigService = RemoteConfigService.instance;
    final remoteConfig = remoteConfigService.config;
    onAdCmu = remoteConfig.getBool('on_ad_cmu');
    if(onAdCmu) {
      clickUrl = remoteConfig.getString('click_url');
      mediaUrl = remoteConfig.getString('media_url');
      if(mediaUrl!='') {
        if(!mounted)return;
        showMediaPopup(context, mediaUrl: mediaUrl, link: clickUrl);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (kIsWeb) { // 페이지 이탈 시 복구
      ref.read(navigationBarHideProvider.notifier).state = false;
    }
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedCmuTabIndex = index; // 캐싱
    });
  }

  void _checkNewFeed() async {
    if (_checkingNewFeed || _alarmOverlay != null) return; // 중복 호출 방지
    _checkingNewFeed = true;
    final service = ref.read(feedService); // FeedService 인스턴스
    final categoryId = selectedCategoryId;

    try {
      final hasNew = await service.isThereNewFeed(
        latestId: latestFeedId ?? 0,
        categoryId: categoryId,
        hotYn: isBestFeedTap ? 1 : 0,
      );

      if (hasNew) {
        _showNewFeedAlarmOverlay();
      } else {
        
      }
    } catch (e) {
      debugPrint('새 피드 체크 중 에러 발생: $e');
    } finally {
      // 짧은 시간 후에 다시 체크 가능하도록 플래그 해제
      await Future.delayed(const Duration(seconds: 5));
      _checkingNewFeed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;

    return Container(
      color: Colors.white,
      child: CustomScrollView( 
        controller: _scrollController,
        slivers: [
          // 상단바 접혔을때 생기는 여백
          SliverAppBar(
            pinned: true, 
            primary: false,
            toolbarHeight: 44 * htio,
            flexibleSpace: Container(
              decoration: const BoxDecoration(color: Colors.white),
            )
          ),
          // 상단바
          SliverPersistentHeader(
          pinned: !_scrolledDown, // 이 부분을 false로 변경
          delegate: CmuAppBarDelegate(
            selectedIndex: _selectedIndex, 
            onTap: _onTap, 
            htio: htio,
            isVisible: !_scrolledDown
          )
        ),
          // 카테고리바
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryTopBarDelegate(
              htio: htio,
              isSpread: isSpread,
              onToggleSpread : toggleSpread,
              onCategoryChange: _categoryChange,
              onHotFeedBtnClick: _getHotFeedBtnClick,
              selectedCategoryId: selectedCategoryId,
            )
          ),
          FeedListSliver(saveLatestIndex: _saveLatestIndex,),
        ],
      ),
    );
  }

  void _showNewFeedAlarmOverlay() {
    var origin = 178;
    var flip = 114;
    var y = (_scrolledDown ? (origin - flip) : origin) * htio;

    final overlay = Overlay.of(context);

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));

    _alarmOverlay?.remove(); // 기존 알람 제거

    _alarmOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + y,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Center(child: CmuNewFeedAlarm(
              onTap: () {
                _alarmOverlay?.remove();
                _alarmOverlay = null;
                ref.read(feedParamsProvider.notifier).state = FeedQueryParams(
                  categoryId: selectedCategoryId,
                  hotYn: isBestFeedTap ? 1 : 0,
                  cursorId: null,
                  limit: 10,
                );
              },
            )),
          ),
        ),
      ),
    );

    overlay.insert(_alarmOverlay!);
    animationController.forward();
}


}