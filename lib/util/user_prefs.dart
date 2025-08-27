import 'dart:convert';

import 'package:my_app/model/usr/auth/token_response.dart';
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
    _myUserId = prefs.getInt('userId');
    _isInitialized = true;
    debugPrint('Loaded myUserId from SharedPreferences: $_myUserId');
  }

  static int? get myUserId => _myUserId; // 사용자 ID에 접근하는 getter

  // 사용자 ID를 설정하는 함수 추가
  static Future<void> setMyUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    _myUserId = userId;
    debugPrint('Set myUserId to SharedPreferences: $_myUserId');
  }

  // 사용자 ID를 제거하는 함수 추가
  static Future<void> clearMyUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _myUserId = null;
    _isInitialized = false;
    debugPrint('Cleared myUserId from SharedPreferences.');
  }

  static Future<void> settingLoginResponse(TokenResponse tokenResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', tokenResponse.accessToken);
    await prefs.setString('refreshToken', tokenResponse.refreshToken!);
    await prefs.setInt('userId', tokenResponse.userId);
    _myUserId = tokenResponse.userId;
  }

  // 앱 재시작 시 호출될 캐시 정리 함수
  static Future<void> cleanExpiredPostViewCache() async {
    debugPrint('앱 시작 시 조회수 캐시 정리 시작');
    final prefs = await SharedPreferences.getInstance();
    
    String? cachedViewsJson = prefs.getString('post_view_cache');
    Map<String, String> currentCachedViews = {};

    if (cachedViewsJson != null && cachedViewsJson.isNotEmpty) {
      try {
        final dynamic decodedData = jsonDecode(cachedViewsJson);

        if (decodedData is Map<dynamic, dynamic>) {
          // 유효한 Map 데이터만 임시로 불러옴
          decodedData.forEach((key, value) {
            if (key is String && value is String) {
              currentCachedViews[key] = value;
            }
          });

          final now = DateTime.now();
          final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
          
          // 만료된 캐시를 저장할 임시 맵
          Map<String, String> updatedCachedViews = {};
          int deletedCount = 0;

          // 모든 캐시 엔트리를 순회하며 만료 여부 확인
          currentCachedViews.forEach((postId, lastViewTimeString) {
            try {
              final lastViewTime = DateTime.parse(lastViewTimeString);
              if (lastViewTime.isBefore(twentyFourHoursAgo)) {
                // 24시간이 지났으면 삭제 대상
                debugPrint('  - 만료된 캐시 삭제: 게시글 ID $postId');
                deletedCount++;
              } else {
                // 유효한 캐시만 updatedCachedViews에 추가
                updatedCachedViews[postId] = lastViewTimeString;
              }
            } catch (e) {
              // 날짜 파싱 오류 발생 시 해당 엔트리 삭제 (데이터 손상으로 간주)
              debugPrint('  - 파싱 오류로 캐시 삭제: 게시글 ID $postId, 데이터: $lastViewTimeString, 에러: $e');
              deletedCount++;
            }
          });

          // 변경된 캐시 맵을 다시 SharedPreferences에 저장
          if (deletedCount > 0 || updatedCachedViews.isEmpty && currentCachedViews.isNotEmpty) {
            await prefs.setString('post_view_cache', jsonEncode(updatedCachedViews)); // 덮어씀으로써 삭제효과
            debugPrint('조회수 캐시 정리 완료. 총 $deletedCount 개의 항목 삭제.');
          } else {
            debugPrint('조회수 캐시에서 삭제된 항목 없음.');
          }
        } else {
          debugPrint('조회수 캐시 데이터 없음.');
        }

        } catch (e) {
          debugPrint('앱 시작 시 캐시 데이터 처리 중 에러 발생. 캐시 초기화: $e');
          await prefs.remove('post_view_cache'); // 심각한 에러 시 전체 캐시 삭제
        }
    }
    debugPrint('조회수 캐시 정리 종료.');
  } 
}