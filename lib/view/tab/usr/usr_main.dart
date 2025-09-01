import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/tab/usr/get_started_screen.dart';
import 'package:my_app/view/tab/usr/usr_info_screen.dart';

class UsrMain extends ConsumerWidget {
  const UsrMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /*
      토큰 검증 
        유효 -> usr_info_screen.dart
        만료 or 없음 -> get_started_screen.dart
    */
    final tokenVerificationResult = ref.watch(jwtTokenVerificationProvider);
    return tokenVerificationResult.when(
      data: (response) {
        if (response.isValid) {
          return const UsrInfoScreen();
        } else {
          return const GetStartedScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: AppLoadingIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint('Token verification error: $error');
        return const GetStartedScreen();
      },
    );
  }
}