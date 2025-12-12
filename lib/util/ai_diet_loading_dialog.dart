import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/util/firebase_remote_config_service.dart' show RemoteConfigService;
import 'package:my_app/util/screen_ratio.dart';
import 'package:my_app/view/common/admob_ads.dart' show AdType, AdmobAds;

/// AI 분석 진행률을 보여주는 커스텀 로딩 다이얼로그 위젯
class AIDietLoadingDialog extends StatefulWidget {
  // AI 분석에 예상되는 최대 시간 (초 단위)
  final int maxDurationSeconds; 

  const AIDietLoadingDialog({
    super.key,
    this.maxDurationSeconds = 18, // 기본값 18초
  });

  @override
  State<AIDietLoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<AIDietLoadingDialog> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // 🚨 광고 애니메이션을 위한 컨트롤러와 애니메이션 추가
  late AnimationController _adController; 
  // 광고 애니메이션 시작 여부 플래그
  bool _adAnimationStarted = false;

  double _currentProgress = 0.0;
  double _elapsedSeconds = 0.0;
  Timer? _timer;

  // 커스텀 광고 존재여부
  late bool _isThereCustomAds;

  @override
  void initState() {
    super.initState();

    /// 회전 애니메이션 (AI 아이콘)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // 🚨 광고 영역 애니메이션 초기화
    _adController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // 0.7초 동안 애니메이션 진행
    );

    initWrapperFunc();
  }

  initWrapperFunc() async {
    await _getInstance();
    await _startProgressSimulation();
  }

  Future<void> _getInstance() async {
    final remoteConfigService = RemoteConfigService.instance;
    final remoteConfig = remoteConfigService.config;
    final bool isAdsOn = remoteConfig.getBool('on_ad');
    if (mounted) {
        setState(() {
            _isThereCustomAds = isAdsOn;
            debugPrint('여부 (setState 후) : $_isThereCustomAds');
        });
    }
  }

  /// maxDurationSeconds 에 맞춰 진행률 속도가 자동 조정되도록 리팩터링
  Future<void> _startProgressSimulation() async {
    const stepDuration = Duration(milliseconds: 100); // 0.1초마다 업데이트
    final double maxSeconds = widget.maxDurationSeconds.toDouble();
    final double stepSeconds = stepDuration.inMilliseconds / 1000.0;

    // 🚨 광고 애니메이션을 시작할 경과 시간
    final double adStartSeconds = maxSeconds * 0.01;

    _timer = Timer.periodic(stepDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // 1. 현재 경과 시간 계산
      _elapsedSeconds = timer.tick * stepSeconds;

      // 2. 경과시간 기반 진행률 (최대 90%까지만 계산)
      // ratio가 1.0을 초과해도 1.0으로 clamp
      double ratio = (_elapsedSeconds / maxSeconds).clamp(0.0, 1.0);
      double targetProgress = ratio * 0.99;

      // 3. 🚨 광고 애니메이션 시작 조건 체크
      if (_elapsedSeconds >= adStartSeconds && !_adAnimationStarted) {
        _adAnimationStarted = true;
        _adController.forward(); // 애니메이션 시작!
      }

      setState(() {
        // maxDurationSeconds(기본 18초)가 지나면 98%에 고정
        _currentProgress = (_elapsedSeconds >= maxSeconds) ? 0.99 : targetProgress;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _adController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { 
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    // 경과 시간을 초 단위로 표시 (소수점 첫째 자리까지)
    final String elapsedText = _elapsedSeconds.toStringAsFixed(1);
    final String maxDurationText = widget.maxDurationSeconds.toString();

    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * wtio),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 25 * htio),
              width: 300 * wtio,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 회전 아이콘
                  RotationTransition(
                    turns: _animation,
                    child: Icon(
                      Icons.auto_fix_high,
                      size: 40 * htio,
                      color: const Color(0xFF0D85E7),
                    ),
                  ),
                  SizedBox(height: 15 * htio),
            
                  Text(
                    'AI 식단 분석 중',
                    style: TextStyle(
                      fontSize: 18 * htio,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pretendard',
                      color: const Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8 * htio),
                  // 🚨 광고 위젯 등장 애니메이션
                  AnimatedSize(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    child: AdmobAds(adType: _isThereCustomAds ? AdType.custom : AdType.nativeVideo),
                  ),
                  Text(
                    '이미지 인식 및 영양 성분 추출에 시간이 소요됩니다.',
                    style: TextStyle(
                      fontSize: 13 * htio,
                      fontFamily: 'Pretendard',
                      color: const Color(0xFF777777),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20 * htio),
            
                  /// 진행률 바
                  LinearProgressIndicator(
                    value: _currentProgress,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D85E7)),
                    minHeight: 8 * htio,
                    borderRadius: BorderRadius.circular(4 * htio),
                  ),
                  SizedBox(height: 10 * htio),
            
                  /// 퍼센트 및 경과 시간 텍스트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(_currentProgress * 100).toStringAsFixed(0)}% 완료',
                        style: TextStyle(
                          fontSize: 12 * htio,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0D85E7),
                        ),
                      ),
                      Text(
                        '경과 시간: ${elapsedText}s / ${maxDurationText}s (예상)',
                        style: TextStyle(
                          fontSize: 12 * htio,
                          fontFamily: 'Pretendard',
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_elapsedSeconds >= 19)
              Positioned(
                right: -9 * wtio, // 다이얼로그 테두리 밖으로 약간 빼내기
                top: -9.5 * htio, // 다이얼로그 테두리 밖으로 약간 빼내기
                child: IconButton(
                  icon: Icon(
                    Icons.cancel, // 동그라미 안에 X 아이콘 (Icons.cancel 사용)
                    size: 24 * htio,
                    color: const Color(0xFFBBBBBB), // 적당한 회색
                  ),
                  onPressed: () {
                    // 다이얼로그 닫기
                    Navigator.of(context).pop(); 
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(), // 최소 크기 제약 해제
                ),
              ),
          ]
        ),
      ),
    );
  }
}

/// 다이얼로그 호출 함수
void showAiAnalysisLoadingDialog(BuildContext context,) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AIDietLoadingDialog();
    },
  );
}