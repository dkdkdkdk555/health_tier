import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  
  /// 저장된 모든 토큰과 사용자 ID를 삭제합니다.
  static Future<void> deleteAllTokens() async {
    final prefs = await SharedPreferences.getInstance();

    // accessToken, refreshToken, userId를 삭제
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');

    debugPrint('모든 토큰과 사용자 ID가 삭제되었습니다.');
  }
}