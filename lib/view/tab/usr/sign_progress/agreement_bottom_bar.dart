import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/view/common/webview_page.dart';
import 'package:my_app/view/tab/usr/sign_progress/nicname_input_page.dart';

class AgreementBottomBar extends StatefulWidget {
  const AgreementBottomBar({super.key});

  @override
  State<AgreementBottomBar> createState() => _AgreementBottomBarState();
}

class _AgreementBottomBarState extends State<AgreementBottomBar> {
  bool agreeTerms = false;       // (필수) 이용약관 동의
  bool agreePrivacy = false;     // (필수) 개인정보 처리방침 동의

  bool get agreeAll => agreeTerms && agreePrivacy;

  void toggleAllAgree() {
    final newValue = !agreeAll;
    setState(() {
      agreeTerms = newValue;
      agreePrivacy = newValue;
    });
  }

  void toggleTerms() {
    setState(() {
      agreeTerms = !agreeTerms;
    });
  }

  void togglePrivacy() {
    setState(() {
      agreePrivacy = !agreePrivacy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
        border: Border(
          left: BorderSide(width: 2, color: Color(0xFF1A1A1A)),
          top: BorderSide(width: 2, color: Color(0xFF1A1A1A)),
          right: BorderSide(width: 2, color: Color(0xFF1A1A1A)),
          bottom: BorderSide(color: Color(0xFF1A1A1A)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 전체 동의하기 Row
            GestureDetector(
              onTap: toggleAllAgree,
              child: Row(
                children: [
                  Icon(
                    size: 22,
                    Icons.check_circle,
                    color: agreeAll ? Colors.white : const Color(0xFF2b2b2b),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '전체 동의하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.3,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.grey, thickness: 0.4),
            const SizedBox(height: 10),

            // (필수) 이용약관 동의
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    toggleTerms();
                  },
                  child: Icon(
                    size: 22,
                    Icons.check_circle,
                    color:  agreeTerms ? Colors.white : const Color(0xFF2b2b2b),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '(필수) 이용약관 동의',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Pretendard',),
                  ),
                ),
                IconButton(
                   onPressed: () {
                    context.push('/usr/agremment?title=${Uri.encodeComponent('이용약관')}&url=${Uri.encodeComponent('https://www.notion.so/24b6746954da80e38112eb00d8636e8c?source=copy_link')}');
                  },
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // (필수) 개인정보 처리방침 동의
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    togglePrivacy();
                  },
                  child: Icon(
                    size: 22,
                    Icons.check_circle,
                    color:  agreePrivacy ? Colors.white : const Color(0xFF2b2b2b),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '(필수) 개인정보처리방침 동의',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Pretendard',),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.push('/usr/agremment?title=${Uri.encodeComponent('개인정보처리방침')}&url=${Uri.encodeComponent('https://www.notion.so/24b6746954da80179890f7f49aac745d?source=copy_link')}');
                  },
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 동의하고 계속하기 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: agreeAll
                    ? () async {
                        final nickname = await context.push<String>('/usr/nicknameInput');

                        if (nickname != null) {
                          debugPrint('✔️ 닉네임 입력 완료: $nickname');
                          if(!context.mounted) return;
                          context.pop();
                        }
                      }
                    : null, // 전체 동의 안하면 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '동의하고 계속하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Pretendard',),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
