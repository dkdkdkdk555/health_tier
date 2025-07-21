

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/service/auth_api_service.dart';

final userAuthService = Provider<AuthApiService>((ref){
  return AuthApiService();
});

final isUserNicknameDupliateProvider = FutureProvider.family<bool, String>((ref, nickname) async {
  final service = ref.watch(userAuthService);
  return service.checkNicknameDuplicate(nickname);
});