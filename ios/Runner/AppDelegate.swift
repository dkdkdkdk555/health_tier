import Flutter
import UIKit
import NidThirdPartyLogin // 1. NidThirdPartyLogin 모듈 임포트 추가
import flutter_local_notifications

// @UIApplicationMain은 @main과 함께 사용되지 않으므로 제거합니다.
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)
      }
      if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 2. NaverThirdPartyLogin 2.1.0 버전을 위한 URL 처리 메서드 추가
  // 이 메서드는 앱이 외부 URL 스킴을 통해 열릴 때 호출됩니다.
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Naver 앱에서 전달된 URL인지 확인하고 처리합니다.
    if (NidOAuth.shared.handleURL(url) == true) {
      return true
    }

  // 다른 플러그인 처리
    return super.application(app, open: url, options: options)
  }
}
