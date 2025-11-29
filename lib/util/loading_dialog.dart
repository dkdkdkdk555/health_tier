import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart';

/// AI 분석 진행률을 보여주는 커스텀 로딩 다이얼로그 위젯
class LoadingDialog extends StatefulWidget {
  // AI 분석에 예상되는 최대 시간 (초 단위)
  final int maxDurationSeconds; 

  const LoadingDialog({
    super.key,
    this.maxDurationSeconds = 18, // 기본값 18초
  });

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double _currentProgress = 0.0;
  double _elapsedSeconds = 0.0;
  Timer? _timer;

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

    _startProgressSimulation();
  }

  /// maxDurationSeconds 에 맞춰 진행률 속도가 자동 조정되도록 리팩터링
  void _startProgressSimulation() {
    const stepDuration = Duration(milliseconds: 100); // 0.1초마다 업데이트
    final double maxSeconds = widget.maxDurationSeconds.toDouble();
    final double stepSeconds = stepDuration.inMilliseconds / 1000.0;

    _timer = Timer.periodic(stepDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // 1. 현재 경과 시간 계산
      _elapsedSeconds = timer.tick * stepSeconds;

      // 2. 종료 조건 확인
      final bool shouldStop = _elapsedSeconds >= maxSeconds;

      // 3. 경과시간 기반 진행률 (최대 90%까지만 계산)
      // ratio가 1.0을 초과해도 1.0으로 clamp
      double ratio = (_elapsedSeconds / maxSeconds).clamp(0.0, 1.0);
      double targetProgress = ratio * 0.98;

      setState(() {
        // 종료 조건에 도달했으면 강제로 98%로 설정, 아니면 계산된 값 사용
        _currentProgress = shouldStop ? 0.98 : targetProgress;
      });

      /// 4. 상태 업데이트 후 타이머 종료
      if (shouldStop) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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
        content: Container(
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
      return const LoadingDialog();
    },
  );
}