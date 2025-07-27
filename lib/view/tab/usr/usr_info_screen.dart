import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsrInfoScreen extends StatefulWidget {
  const UsrInfoScreen({super.key});

  @override
  State<UsrInfoScreen> createState() => _UsrInfoScreenState();
}

class _UsrInfoScreenState extends State<UsrInfoScreen> {
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
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 44,),
          const CmuBasicAppBar(centerText: '회원정보 페이지'),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _jwtToken == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '로그인 되었습니다.',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text('JWT Token:', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        _jwtToken!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
