import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsrInfoScreen extends ConsumerStatefulWidget {
  const UsrInfoScreen({super.key});

  @override
  ConsumerState<UsrInfoScreen> createState() => _UsrInfoScreenState();
}

class _UsrInfoScreenState extends ConsumerState<UsrInfoScreen> {
  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    _loadJwtToken();
  }

  Future<void> _loadJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    setState(() {
      _jwtToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final badgeResult = ref.watch(userBadgeListProvider(30));

    final latestWeightAsyncValue = ref.watch(getLatestWeightProvider);

    return latestWeightAsyncValue.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (weight) {
        if (weight != null) {
          return Text('가장 최근 체중: $weight kg');
        } else {
          return const Text('아직 체중 기록이 없습니다.');
        }
      },
    );

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

    // return Scaffold(
    //   body: Column(
    //     children: [
    //       const SizedBox(height: 44,),
    //       Padding(
    //         padding: const EdgeInsets.all(20.0),
    //         child: _jwtToken == null
    //             ? const Center(child: CircularProgressIndicator())
    //             : Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   const Text(
    //                     '로그인 되었습니다.',
    //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //                   ),
    //                   const SizedBox(height: 20),
    //                   const Text('JWT Token:', style: TextStyle(fontSize: 16)),
    //                   const SizedBox(height: 8),
    //                   Text(
    //                     _jwtToken!,
    //                     style: const TextStyle(fontSize: 12, color: Colors.grey),
    //                   ),
    //                 ],
    //               ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
