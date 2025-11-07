import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textWidth;
  late String _selectedIntro;

  @override
  void initState() {
    super.initState();

    // intro1~3 중 랜덤 선택
    final random = Random();
    final introIndex = random.nextInt(3) + 1; // 1~3
    _selectedIntro = 'assets/image/intro$introIndex.json';

    // 텍스트 애니메이션 컨트롤러
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _textWidth = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    // 로고 애니메이션 이후 텍스트 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie 로고

            Padding(
              padding: EdgeInsets.only(left: 35 * wtio),
              child: Lottie.asset(
                _selectedIntro,
                width: 150 * wtio,
                repeat: false,
                animate: true,
              ),
            ),
            SizedBox(height: 3*htio),

            // 텍스트 애니메이션
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _textWidth.value, // 왼쪽에서 오른쪽으로 확장
                    child: child,
                  ),
                );
              },
              child: Text(
                'HealthTier',
                style: TextStyle(
                  fontSize: 22 * htio,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            SizedBox(height: 150*htio,)
          ],
        ),
      ),
    );
  }
}
