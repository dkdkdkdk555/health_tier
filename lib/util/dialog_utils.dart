import 'package:flutter/material.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:table_calendar/table_calendar.dart';

// 공통 달력 다이얼로그
Future<DateTime?> showDayPicker(BuildContext context, DateTime initialDate,) {
  final double heightRatio = ScreenRatio(context).heightRatio;
  final double widthRatio = ScreenRatio(context).widthRatio;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      DateTime selectedDate = initialDate;

      return Dialog(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 400 * heightRatio,
                    width: 350 * widthRatio,
                    child: TableCalendar(
                      locale: 'ko_KR',
                      rowHeight: 50 * heightRatio,
                      daysOfWeekHeight: 20 * heightRatio,
                      firstDay: DateTime(2022, 1, 1),
                      lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                      focusedDay: selectedDate,
                      selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                      onDaySelected: (day, _) {
                        Navigator.of(context).pop(day); // ← day로 수정하는 게 맞음
                      },
                      onPageChanged: (day) => setState(() => selectedDate = day),
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: '', // ← 드롭다운 제거
                      },
                      headerStyle: const HeaderStyle(
                        titleCentered: true, // ← 년월 가운데 정렬
                        formatButtonVisible: false, // ← format 드롭다운 숨기기
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

// 공통 다이얼로그 호출 함수
Future<void> showAppDialog(
  BuildContext context, {
  String? title,
  bool barrierDismiss = true,
  required String message,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismiss,
    builder: (context) {
      return buildAppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          Navigator.pop(context);
          onConfirm?.call();
        },
        onCancel: () {
          Navigator.pop(context);
          onCancel?.call();
        },
      );
    },
  );
}
/// 공통 다이얼로그 위젯
AlertDialog buildAppDialog({
  String? title,
  required String message,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    backgroundColor: Colors.white,
    title: title!=null ? Text(
      title,
      style: const TextStyle(
        fontFamily: "Pretendard",
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ) : null,
    content: Text(
      message,
      style: const TextStyle(
        fontFamily: "Pretendard",
        fontSize: 14,
        color: Colors.black87,
      ),
    ),
    actions: [
      cancelText != null ? TextButton(
        onPressed: onCancel,
        child: Text(cancelText),
      ) : const SizedBox.shrink(),
      confirmText != null ? ElevatedButton(
        onPressed: onConfirm,
        child: Text(confirmText),
      ) : const SizedBox.shrink(),
    ],
  );
}


/// 공통 입력 다이얼로그
Future<String?> showInputDialog(
  BuildContext context, {
  String? title,
  String? hintText,
  String confirmText = "확인",
  String cancelText = "취소",
  int minLines = 1,
  int maxLines = 1,
  int? maxLength,
}) {
  final TextEditingController controller = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // 바깥 터치로 닫히지 않게
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: title != null
            ? Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
            : null,
        content: TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                  color: Theme.of(context).primaryColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          cursorColor: Theme.of(context).primaryColor,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text("내용을 입력해주세요.")),
                );
                return;
              }
              Navigator.pop(dialogContext, text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              elevation: 0,
            ),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}
