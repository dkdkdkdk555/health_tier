

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/auth/token_verification_response.dart';
import 'package:my_app/service/auth_api_service.dart';

final userAuthService = Provider<AuthApiService>((ref){
  return AuthApiService();
});

// 가입시 닉네임 중복여부 검사
final isUserNicknameDupliateProvider = FutureProvider.family<bool, String>((ref, nickname) async {
  final service = ref.watch(userAuthService);
  return service.checkNicknameDuplicate(nickname);
});
// 토큰검증 프로바이더
final jwtTokenVerificationProvider = FutureProvider<TokenVerificationResponse>((ref) async {
  final authService = ref.watch(userAuthService);
  try {
    return await authService.verifyToken();
  } catch (e) {
    return TokenVerificationResponse(isValid: false, error: e.toString());
  }
});