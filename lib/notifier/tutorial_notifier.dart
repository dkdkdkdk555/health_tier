// 튜토리얼 완료 여부를 관리하는 프로바이더
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final mainTutorialStorageProvider = StateNotifierProvider<MainTutorialNotifier, bool>((ref) {
  return MainTutorialNotifier();
});

class MainTutorialNotifier extends StateNotifier<bool> {
  MainTutorialNotifier() : super(false) { // 기본값은 '이미 봤음'으로 설정하고 초기화 때 확인
  }
  static const _key = 'is_main_tutorial_shown';
  // 튜토리얼을 본 후 호출할 함수
  Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }
}

///////////////////

final dietTutorialStorageProvider = StateNotifierProvider<DietTutorialNotifier, bool>((ref) {
  return DietTutorialNotifier();
});

class DietTutorialNotifier extends StateNotifier<bool> {
  DietTutorialNotifier() : super(false) { // 기본값은 '이미 봤음'으로 설정하고 초기화 때 확인
  }
  static const _key = 'is_diet_tutorial_shown';
  // 튜토리얼을 본 후 호출할 함수
  Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }
}

///////////////////

final dietWriteTutorialStorageProvider = StateNotifierProvider<DietWriteTutorialNotifier, bool>((ref) {
  return DietWriteTutorialNotifier();
});

class DietWriteTutorialNotifier extends StateNotifier<bool> {
  DietWriteTutorialNotifier() : super(false) { // 기본값은 '이미 봤음'으로 설정하고 초기화 때 확인
  }
  static const _key = 'is_diet_write_tutorial_shown';
  // 튜토리얼을 본 후 호출할 함수
  Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }
}