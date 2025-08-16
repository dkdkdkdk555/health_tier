import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';
import 'package:my_app/view/tab/usr/management/usr_app_bar_preferredsize.dart';

//내정보관리
class UsrInfoManagement extends ConsumerStatefulWidget {
  const UsrInfoManagement({super.key});

  @override
  ConsumerState<UsrInfoManagement> createState() => _UsrInfoManagementState();
}

class _UsrInfoManagementState extends ConsumerState<UsrInfoManagement> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: UsrAppBarPreferredsize(centerText: '내 정보 관리',),
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