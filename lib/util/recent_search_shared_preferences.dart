import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesManager {
  static const String _kRecentSearchesKey = 'recent_search_keywords';
  static const int _maxRecentSearches = 10; // 최대 저장할 검색어 개수

  // 최근 검색어 불러오기
  static Future<List<String>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kRecentSearchesKey) ?? [];
  }

  // 최근 검색어 저장 (추가 및 중복 제거)
  static Future<void> addSearchKeyword(String keyword) async {
    if (keyword.trim().isEmpty) return; // 빈 검색어는 저장하지 않음

    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList(_kRecentSearchesKey) ?? [];

    // 중복 제거: 기존에 같은 검색어가 있으면 제거하고 맨 앞으로 보냄
    searches.remove(keyword);
    // 새 검색어를 맨 앞에 추가
    searches.insert(0, keyword);

    // 최대 개수 유지
    if (searches.length > _maxRecentSearches) {
      searches = searches.sublist(0, _maxRecentSearches);
    }

    await prefs.setStringList(_kRecentSearchesKey, searches);
  }

  // 개별 최근 검색어 삭제
  static Future<void> removeSearchKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList(_kRecentSearchesKey) ?? [];
    searches.remove(keyword); // 해당 검색어 제거
    await prefs.setStringList(_kRecentSearchesKey, searches);
  }

  // 모든 최근 검색어 삭제
  static Future<void> clearAllSearches() async { // 메서드명 변경 (clearRecentSearches -> clearAllSearches)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentSearchesKey);
  }
}