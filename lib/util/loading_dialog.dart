import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart'; // ScreenRatio가 해당 경로에 있다고 가정

/// AI 분석 진행률을 보여주는 커스텀 로딩 다이얼로그 위젯
class LoadingDialog extends StatefulWidget {
  // AI 분석에 예상되는 최대 시간 (20초)
  final int maxDurationSeconds; 

  const LoadingDialog({
    super.key,
    this.maxDurationSeconds = 23,
  });

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentProgress = 0.0;
  int _elapsedTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // 1. 애니메이션 컨트롤러 초기화 (로딩 인디케이터용)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2초마다 반복
    )..repeat();
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // 2. 타이머 시작 (23초 동안 진행률 시뮬레이션)
    _startProgressSimulation();
  }

  void _startProgressSimulation() {
    const stepDuration = Duration(milliseconds: 100); // 0.1초마다 업데이트
    int totalSteps = (widget.maxDurationSeconds * 1000) ~/ stepDuration.inMilliseconds;
    int currentStep = 0;

    _timer = Timer.periodic(stepDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _elapsedTime = timer.tick * stepDuration.inSeconds; // 경과 시간 (초 단위)
        currentStep++;
        
        // 시간 기반으로 진행률 계산 (0%에서 90%까지만 시뮬레이션)
        // 실제 API 응답이 오면 나머지 10%가 즉시 채워짐
        double targetProgress = (currentStep / totalSteps) * 0.9; 
        _currentProgress = targetProgress;

        if (_elapsedTime >= widget.maxDurationSeconds) {
          // 최대 시간을 초과하면 90%에서 멈춤
          _currentProgress = 0.9;
          timer.cancel();
        }
      });
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
    
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false, // 로딩 중에는 뒤로가기 버튼 비활성화
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * wtio)),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 25 * htio),
          width: 300 * wtio,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 스피너 애니메이션 (AI 분석 상징)
              RotationTransition(
                turns: _animation,
                child: Icon(
                  Icons.auto_fix_high, // AI 작업을 상징하는 아이콘
                  size: 40 * htio,
                  color: const Color(0xFF0D85E7),
                ),
              ),
              SizedBox(height: 15 * htio),
              
              // 타이틀
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

              // 설명 텍스트
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

              // 진행률 표시줄
              LinearProgressIndicator(
                value: _currentProgress,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D85E7)),
                minHeight: 8 * htio,
                borderRadius: BorderRadius.circular(4 * htio),
              ),

              SizedBox(height: 10 * htio),

              // 진행률 퍼센트 및 경과 시간
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
                    '경과 시간: ${_elapsedTime}s / ${widget.maxDurationSeconds}s (예상)',
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

/// 커스텀 로딩 다이얼로그를 표시하는 함수
void showAiAnalysisLoadingDialog(BuildContext context, {int maxDurationSeconds = 20}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LoadingDialog(maxDurationSeconds: maxDurationSeconds);
    },
  );
}