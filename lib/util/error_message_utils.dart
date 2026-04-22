import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/extension/screen_ratio_extension.dart' show ScreenRatio;
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/navigator_key.dart' show navigatorKey;
import 'package:my_app/view/tab/usr/get_started_screen.dart' show GetStartedScreen;

/// 메시지 타입
enum AppMessageType { snackBar, dialog }

/* 
  showAppMessage(context, message: '');
*/
/// 공통 메시지 출력 함수
Future<void> showAppMessage(
  BuildContext context, {
  String message = "오류가 발생했습니다.",
  AppMessageType type = AppMessageType.snackBar,
  String? title,
  String confirmText = "확인",
  VoidCallback? onConfirm,
  bool loginRequest = false,
}) async {
  final htio = ScreenRatio(context).heightRatio;
  switch (type) {
    case AppMessageType.snackBar:
      // 기존 SnackBar 제거 후 새로 표시
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(
                fontFamily: "Pretendard",
                fontSize: 14 * htio,
              ),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      break;

    case AppMessageType.dialog:
      await showAppDialog(
        context,
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: loginRequest ?
        () {
          if(onConfirm!=null) {
            onConfirm();
          }
          context.go('/usr/login');
        } : () {}
      );
      break;
  }
}
