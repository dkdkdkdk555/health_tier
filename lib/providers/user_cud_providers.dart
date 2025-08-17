// 인증된 Dio 인스턴스를 제공
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/model/usr/user/usr_simple_dto.dart';
import 'package:my_app/service/user_api_service.dart';

final authDioProvider = FutureProvider<Dio>((ref) async {
  return DIOConfig().createAuthDio(ref);
});

// UserApiService를 provider로 제공
final userCudServiceProvider = FutureProvider<UserApiService>((ref) async {
  final dio = await ref.watch(authDioProvider.future);
  return UserApiService(dio);
});

// 사용자 뱃지 조회 provider
final userBadgeListProvider = FutureProvider.family<Result<List<BadgeInfoDto>>, int>((ref, userId) async {
  final service = await ref.watch(userCudServiceProvider.future);
  return await service.getUserBadges(userId);
});

// 백업 상태를 가져오는 Provider
final backupStatusProvider = FutureProvider<String>((ref) async {
  final userService = await ref.watch(userCudServiceProvider.future);
  return userService.getBackupStatus();
});

// 내정보관리에서 사용자정보 공급
final usrSimpleInfoProvider = FutureProvider<Result<UserSimpleDto>>((ref) async {
  final service = await ref.watch(userCudServiceProvider.future);
  return await service.getUserSimpleInfo();
});