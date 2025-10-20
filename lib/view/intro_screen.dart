import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_router 안 쓰면 Navigator.push 사용 가능

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();

    // 2초 후 홈 화면으로 이동
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Image.asset(
              'assets/image/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'HealthTier',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
