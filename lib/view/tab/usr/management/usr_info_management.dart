import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/util/dialog_utils.dart' show showConfirmDialog;
import 'package:my_app/util/token_manager.dart';
import 'package:my_app/view/common/webview_page.dart';
import 'package:my_app/view/tab/usr/get_started_screen.dart';
import 'package:my_app/view/tab/usr/management/doc_backup_and_restore.dart';
import 'package:my_app/view/tab/usr/management/usr_app_bar_preferredsize.dart';
import 'package:my_app/view/tab/usr/management/usr_info_profile.dart';
import 'package:my_app/view/tab/usr/management/usr_signout_notice_page.dart';

//내정보관리
class UsrInfoManagement extends ConsumerStatefulWidget {
  const UsrInfoManagement({super.key});

  @override
  ConsumerState<UsrInfoManagement> createState() => _UsrInfoManagementState();
}

class _UsrInfoManagementState extends ConsumerState<UsrInfoManagement> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UsrAppBarPreferredsize(centerText: '내 정보 관리',),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const UsrInfoProfile(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  makeTitle('동의약관'),
                  const SizedBox(height: 10,),
                  makeItem('이용약관', 'https://www.notion.so/24b6746954da80e38112eb00d8636e8c?source=copy_link'),
                  makeItem('개인정보처리방침', 'https://www.notion.so/24b6746954da80179890f7f49aac745d?source=copy_link'),
                  const SizedBox(height: 30,),
                  makeTitle('기록 옮기기'),
                  const DocBackupAndRestore(),
                  const SizedBox(height: 50,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await showConfirmDialog(context, message: '로그아웃 하시겠습니까?');

                        if(confirm){
                          TokenManager.deleteAllTokens();
                          if(!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const GetStartedScreen()),
                            (route) => false,
                          );

                        }
                      },
                      child: Text(
                        '로그아웃',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15.3,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.normal,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                         Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) => const UsrSignoutNoticePage()
                            )
                          );
                      },
                      child: Text(
                        '회원탈퇴',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15.3,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.normal,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Align makeTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.bold,
          height: 1.6,
        ),
      ),
    );
  }

  Align makeItem(String text, String link) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          IconButton(
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WebViewPage(
                    title: text,
                    url: link,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}