
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SrchKeywordNotifier extends StateNotifier<String> {
  SrchKeywordNotifier() : super(''); // 초기 상태를 빈 문자열로 설정

  // 검색어 업데이트 (상태 변경)
  // 이 메서드를 호출하여 현재 검색어 상태를 변경합니다.
  void updateKeyword(String newKeyword) {
    if (state != newKeyword) { // 불필요한 상태 업데이트 방지
      state = newKeyword;
    }
  }

  // 검색어 초기화 (옵션)
  // 검색 입력 필드를 비우거나 초기 상태로 되돌릴 때 사용합니다.
  void clearKeyword() {
    state = '';
  }

}

// 이 StateNotifier를 위한 Riverpod Provider
final srchKeywordProvider = StateNotifierProvider<SrchKeywordNotifier, String>((ref) {
  return SrchKeywordNotifier();
});