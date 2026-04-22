import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  // 1. Singleton 인스턴스를 private static 변수로 선언
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  // 2. private 생성자를 만들어 외부에서 직접 인스턴스 생성을 막음
  RemoteConfigService._internal();

  // 3. getter를 통해 유일한 인스턴스에 접근하도록 허용 (앱 전역에서 사용될 접근점)
  static RemoteConfigService get instance => _instance;

  // 4. FirebaseRemoteConfig 인스턴스를 저장할 private 변수
  late final FirebaseRemoteConfig _remoteConfig;

  // 5. 초기화 상태를 추적할 플래그
  bool _isInitialized = false;
  
  // 6. 초기화 및 설정을 수행하는 메서드 (반드시 앱 시작 시 한 번 호출)
  Future<void> initialize() async {
    if (_isInitialized) return; // 이미 초기화되었다면 무시
    
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));

    try {
      // 즉시 패치 및 활성화 시도
      await _remoteConfig.fetchAndActivate();
      _isInitialized = true;
      debugPrint('RemoteConfigService 초기화 및 활성화 완료.');
    } catch (e) {
      debugPrint('RemoteConfigService 초기화 실패: $e');
    }
  }

  // 7. 앱 전역에서 Remote Config 값에 접근할 수 있는 getter 제공
  FirebaseRemoteConfig get config => _remoteConfig;
  
  // 8. 필요하다면, 버전 비교 로직 등 자주 사용하는 메서드를 여기에 추가할 수 있습니다.
  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
}