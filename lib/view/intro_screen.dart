import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textWidth;

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Lottie 로고
            Lottie.asset(
              'assets/image/logo_temp60.json',
              width: 120,
              repeat: false,
              animate: true,
            ),
            const SizedBox(height: 18),

            // 🔹 텍스트 애니메이션
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
              child: const Text(
                'HealthTier',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
