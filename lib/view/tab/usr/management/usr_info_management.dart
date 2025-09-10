import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/usr/user/usr_simple_dto.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/token_manager.dart';
import 'package:my_app/view/common/webview_page.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';
import 'package:my_app/view/tab/usr/get_started_screen.dart';
import 'package:my_app/view/tab/usr/management/doc_backup_and_restore.dart';
import 'package:my_app/view/tab/usr/management/usr_info_profile.dart';
import 'package:my_app/view/tab/usr/management/usr_signout_notice_page.dart';

//내정보관리
class UsrInfoManagement extends ConsumerStatefulWidget {
  final UserSimpleDto userInfo;
  const UsrInfoManagement({
    super.key,
    required this.userInfo,
  });

  @override
  ConsumerState<UsrInfoManagement> createState() => _UsrInfoManagementState();
}

class _UsrInfoManagementState extends ConsumerState<UsrInfoManagement> {

  var htio = 0.0;
  var wtio = 0.0;

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height:44 * htio),
            const CmuBasicAppBar(centerText: '내 정보 관리',),
            UsrInfoProfile(userInfo: widget.userInfo),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 25 * htio),
              child: Column(
                children: [
                  makeTitle('동의약관'),
                  SizedBox(height: 10 * htio,),
                  makeItem('이용약관', 'https://www.notion.so/24b6746954da80e38112eb00d8636e8c?source=copy_link'),
                  makeItem('개인정보처리방침', 'https://www.notion.so/24b6746954da80179890f7f49aac745d?source=copy_link'),
                  SizedBox(height: 30 * htio,),
                  makeTitle('기록 옮기기'),
                  const DocBackupAndRestore(),
                  SizedBox(height: 50 * htio,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () async {
                         await showAppDialog(
                          context, 
                          message: '로그아웃 하시겠습니까?',
                          confirmText: '확인',
                          cancelText: '취소',
                          onConfirm: () {
                            TokenManager.deleteAllTokens();
                            if(!context.mounted) return;
                            context.go('/usr/login'); // 현재 네비게이션 스택을 전부 날리고 이동
                          },
                          onCancel: () {
                            return;
                          },
                        );
                      },
                      child: Text(
                        '로그아웃',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15.3 * htio,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.normal,
                          height: 1.6 * htio,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * htio,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        context.push('/usr/info/management/signout');
                      },
                      child: Text(
                        '회원탈퇴',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15.3 * htio,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.normal,
                          height: 1.6 * htio,
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
        style: TextStyle(
          color: Colors.black,
          fontSize: 18 * htio,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.bold,
          height: 1.6 * htio,
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
              fontSize: 16 * htio,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.bold,
              height: 1.6 * htio,
            ),
          ),
          IconButton(
            onPressed: () {
              context.push('/usr/agremment?title=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(link)}');
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