import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/view/tab/usr/management/doc_backup_and_restore.dart';
import 'package:my_app/view/tab/usr/management/usr_info_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsrInfoScreen extends ConsumerStatefulWidget {
  const UsrInfoScreen({super.key});

  @override
  ConsumerState<UsrInfoScreen> createState() => _UsrInfoScreenState();
}

class _UsrInfoScreenState extends ConsumerState<UsrInfoScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 84,),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
               MaterialPageRoute(
                builder: (context) => const UsrInfoManagement()
                )
              );
            },
            child: Text(
              '내정보관리',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade400
              ),
            ),
          )
        ],
      ),
    );
  }
}
