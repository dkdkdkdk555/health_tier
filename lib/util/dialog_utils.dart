import 'package:flutter/material.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/common/video_display.dart' show VideoDisplay;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extension/screen_ratio_extension.dart' show ScreenRatio;

// 공통 달력 다이얼로그
Future<DateTime?> showDayPicker(
  BuildContext context,
  DateTime initialDate,
) {
  final double heightRatio = ScreenRatio(context).heightRatio;
  final double widthRatio = ScreenRatio(context).widthRatio;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      DateTime selectedDate = initialDate;

      return Dialog(
        backgroundColor: Colors.white,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 15 * widthRatio, vertical: 16 * heightRatio),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 409 * heightRatio,
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
                        Navigator.of(context).pop(day);
                      },
                      onPageChanged: (day) => setState(() => selectedDate = day),
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: '',
                      },
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF0D85E7),
                          shape: BoxShape.rectangle
                        )
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
  final double heightRatio = ScreenRatio(context).heightRatio;
  final double widthRatio = ScreenRatio(context).widthRatio;

  return showDialog(
    context: context,
    barrierDismissible: barrierDismiss,
    builder: (context) {
      return buildAppDialog(
        widthRatio,
        heightRatio,
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

// 공통 다이얼로그 위젯
AlertDialog buildAppDialog(
  double widthRatio,
  double heightRatio,
  {
  String? title,
  required String message,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {

  // 버튼들을 리스트로 준비
  final List<Widget> buttons = [];

  if (cancelText != null) {
    buttons.add(
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * widthRatio),
            ),
          ),
          onPressed: onCancel,
          child: Text(cancelText, style: TextStyle(fontSize: 14 * heightRatio)),
        ),
      ),
    );
  }

  if (confirmText != null) {
    buttons.add(
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D86E7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * widthRatio),
            ),
          ),
          onPressed: onConfirm,
          child: Text(confirmText, style: TextStyle(fontSize: 14 * heightRatio)),
        ),
      ),
    );
  }

  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16 * widthRatio),
    ),
    backgroundColor: Colors.white,
    actionsPadding: EdgeInsets.symmetric(horizontal: 10 * widthRatio, vertical: 10 * heightRatio),
    title: title != null
        ? Text(
            title,
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 18 * heightRatio,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
    content: Text(
      message,
      style: TextStyle(
        fontFamily: "Pretendard",
        fontSize: 14 * heightRatio,
        color: Colors.black87,
      ),
    ),
    actions: [
      Row(
        children: [
          ...buttons.expand((btn) sync* {
            yield btn;
            if (btn != buttons.last) {
              yield SizedBox(width: 8 * widthRatio); // 버튼 사이 간격
            }
          }),
        ],
      ),
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
  final double heightRatio = ScreenRatio(context).heightRatio;
  final double widthRatio = ScreenRatio(context).widthRatio;
  final TextEditingController controller = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0 * widthRatio),
        ),
        backgroundColor: Colors.white,
        actionsPadding: EdgeInsets.symmetric(horizontal: 10 * widthRatio, vertical: 10 * heightRatio),
        title: title != null
            ? Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18 * heightRatio,
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
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14 * heightRatio, // 폰트 크기 반응형
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0 * widthRatio),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0 * widthRatio),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0 * widthRatio),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15 * widthRatio,
              vertical: 12 * heightRatio,
            ),
          ),
          cursorColor: Theme.of(context).primaryColor,
          style: TextStyle(fontSize: 14 * heightRatio), // 폰트 크기 반응형
        ),
        actions: [
          Row(
            children: [
              // 취소 버튼
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFDDDDDD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * widthRatio),
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, null),
                  child: Text(cancelText, style: TextStyle(fontSize: 14 * heightRatio)),
                ),
              ),
              SizedBox(width: 8 * widthRatio),
              // 확인 버튼
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D86E7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * widthRatio),
                    ),
                  ),
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
                  child: Text(confirmText, style: TextStyle(fontSize: 14 * heightRatio)),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

// 공통 전체 이미지 뷰어 함수
void openFullImageView(BuildContext context, String imgUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black87,
    pageBuilder: (_, __, ___) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: InteractiveViewer(
            maxScale: 5.0,
            minScale: 0.5,
            child: Image.network(
              imgUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    },
  );
}


void showMediaPopup(
  BuildContext context, {
  required String mediaUrl,
  required String link,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => _MediaPopup(mediaUrl: mediaUrl, link: link,),
  );
}

class _MediaPopup extends StatelessWidget {
  final String mediaUrl;
  final String link;

  const _MediaPopup({
    required this.mediaUrl,
    required this.link,
  });

  bool _isVideoUrl(String url) {
    url = url.toLowerCase();
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.webm');
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    final double popupWidth = size.width - (40*wtio); // 좌우 padding 20
    final double popupHeight = (size.height * 2 / 3) * htio;
    

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 팝업 본체
            Container(
              width: popupWidth,
              height: popupHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isVideoUrl(mediaUrl)
                  ? VideoDisplay(videoUrl: mediaUrl)
                  : Image.network(
                      mediaUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
            ),
             // 오늘 하루 보지 않기
            GestureDetector(
              onTap: () async {
                await UserPrefs.hideAdForToday();
                if(!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14 * wtio, vertical: 6 * htio),
                margin: EdgeInsets.only(left: 7.6 * wtio, top:7.6 * htio),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(80),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '오늘 하루 동안 열지 않음',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12 * htio,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6*wtio),
            // 닫기 버튼 (우측 상단)
            Positioned(
              right: -5 * wtio,
              top: -5 * htio,
              child: IconButton(
                icon: Icon(
                  Icons.cancel,
                  size: 26 * htio,
                  color: Colors.white70,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // 링크 버튼 (가운데 하단)
            Positioned(
              bottom: 16 * htio,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 18 * wtio, vertical: 10 * htio),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80), // 반투명 배경
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '자세히 보러가기 >>',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * htio,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2 * wtio,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void showInstallRcmndPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => _InstallRcmndPopup(),
  );
}

class _InstallRcmndPopup extends StatelessWidget {
  const _InstallRcmndPopup();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 팝업 본체
            Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://s3.ap-northeast-2.amazonaws.com/s3.health-tier.com/uploads/popup.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 6 * wtio),
            // 닫기 버튼 (우측 상단)
            Positioned(
              right: 4 * wtio,
              top: 3 * htio,
              child: IconButton(
                icon: Icon(
                  Icons.cancel,
                  size: 26 * htio,
                  color: Colors.white70,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // 링크 버튼 (가운데 하단)
            Positioned(
              bottom: 75 * htio,
              left: -245,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    await launchUrl(
                        Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.health.tier&hl=ko'),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    width: 144.3,
                    padding: EdgeInsets.symmetric(
                        horizontal: 18 * wtio, vertical: 10 * htio),
                    decoration: BoxDecoration(
                      color: const Color(0xFF59A710).withAlpha(220),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Google Play 설치',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * htio,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2 * wtio,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 120 * htio,
              left: -245,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    await launchUrl(
                        Uri.parse('https://apps.apple.com/kr/app/id6753325210'),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    width: 144.3,
                    padding: EdgeInsets.symmetric(
                        horizontal: 18 * wtio, vertical: 10 * htio),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D85E7).withAlpha(200),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'App Store 설치',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * htio,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2 * wtio,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
