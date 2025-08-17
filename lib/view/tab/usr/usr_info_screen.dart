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
  // String? _jwtToken;

  @override
  void initState() {
    super.initState();
    // _loadJwtToken();
  }

  // Future<void> _loadJwtToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('accessToken');

  //   debugPrint('_loadJwtToken 토큰 : $token');
  //   setState(() {
  //     _jwtToken = token;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // final badgeResult = ref.watch(userBadgeListProvider(30));

    // final latestWeightAsyncValue = ref.watch(getLatestWeightProvider);

    // return latestWeightAsyncValue.when(
    //   loading: () => const CircularProgressIndicator(),
    //   error: (err, stack) => Text('Error: $err'),
    //   data: (weight) {
    //     if (weight != null) {
    //       return Text('가장 최근 체중: $weight kg');
    //     } else {
    //       return const Text('아직 체중 기록이 없습니다.');
    //     }
    //   },
    // );
    // return badgeResult.when(
    //   data: (result) => ListView.builder(
    //     itemCount: result.data.length,
    //     itemBuilder: (context, index) {
    //       final badge = result.data[index];
    //       return ListTile(
    //         title: Text(badge.badgeName),
    //         subtitle: Text(badge.badgeCtnt!),
    //       );
    //     },
    //   ),
    //   loading: () => const CircularProgressIndicator(),
    //   error: (e, st) => Text('에러 발생: $e'),
    // );

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
