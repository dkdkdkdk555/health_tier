import 'package:flutter/material.dart';
import 'package:my_app/view/tab/usr/management/usr_app_bar_preferredsize.dart';

class UsrSignoutNoticePage extends StatelessWidget {
  const UsrSignoutNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: UsrAppBarPreferredsize(centerText: '회원탈퇴',),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            
          ],
        ),
      ),
    );
  }
}