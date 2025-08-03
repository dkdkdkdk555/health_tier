import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserPrefs {
  static int? _myUserId; // 전역으로 접근 가능한 사용자 ID 저장

  // 초기화되었는지 확인하는 플래그 (선택 사항)
  static bool _isInitialized = false;

  static Future<void> loadMyUserId() async {
    if (_isInitialized) {
      debugPrint('User ID already loaded: $_myUserId');
      return; // 이미 로드되었다면 다시 로드할 필요 없음
    }
    final prefs = await SharedPreferences.getInstance();
    _myUserId = prefs.getInt('myUserId') ?? 30; //28; //✅임시userId
    _isInitialized = true;
    debugPrint('Loaded myUserId from SharedPreferences: $_myUserId');
  }

  static int? get myUserId => _myUserId; // 사용자 ID에 접근하는 getter

  // 사용자 ID를 설정하는 함수 추가
  static Future<void> setMyUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('myUserId', userId);
    _myUserId = userId;
    debugPrint('Set myUserId to SharedPreferences: $_myUserId');
  }

  // 사용자 ID를 제거하는 함수 추가
  static Future<void> clearMyUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('myUserId');
    _myUserId = null;
    _isInitialized = false;
    debugPrint('Cleared myUserId from SharedPreferences.');
  }
}