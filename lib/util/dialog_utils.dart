import 'package:flutter/material.dart';

/// 공통 확인 다이얼로그
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String message,
  String cancelText = "취소",
  String confirmText = "확인",
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText),
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
          ),
          TextButton(
            child: Text(confirmText),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
          ),
        ],
      );
    },
  );
  return result ?? false;
}
