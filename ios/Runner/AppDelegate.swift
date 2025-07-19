import Flutter
import UIKit
import NidThirdPartyLogin // 1. NidThirdPartyLogin 모듈 임포트 추가

// @UIApplicationMain은 @main과 함께 사용되지 않으므로 제거합니다.
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
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

    // 다른 플러그인이나 앱에서 URL 처리가 필요한 경우, 여기에 추가 로직을 넣을 수 있습니다.
    // 예를 들어, 다른 소셜 로그인(카카오, 구글 등)이나 딥링크 처리가 있다면 이 부분에 추가합니다.
    // 이 경우, `super.application` 호출을 통해 Flutter 플러그인들이 URL을 처리할 수 있도록 합니다.
    // 현재는 Naver가 처리하지 않으면 바로 false를 반환하도록 되어 있으나,
    // 다른 Flutter 플러그인들이 URL을 처리해야 한다면 아래 라인을 사용하세요.
    // return super.application(app, open: url, options: options)

    // Naver가 처리하지 않았고, 다른 플러그인 처리도 필요 없다면 false 반환
    return false
  }
}