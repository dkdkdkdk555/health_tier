import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';

class UserApiService {

  final Dio dio;
  UserApiService(this.dio);

  // 사용자 뱃지 조회
  Future<Result<List<BadgeInfoDto>>> getUserBadges(int userId) async {
    final response = await dio.get('${UserCudAPI.getUserBadges}/$userId');
    return Result.fromJson(
      response.data,
      (obj) => (obj as List).map((e) => BadgeInfoDto.fromJson(e)).toList(),
    );
  }

  // 1. 데이터 백업 요청
  Future<String> requestBackup(String backupJson) async {
    final response = await dio.post(
      UserCudAPI.backupRequest,
      data: backupJson,
      options: Options(contentType: Headers.jsonContentType),
    );
    return response.data;
  }

  // 2. 데이터 백업 상태 확인
  Future<String> getBackupStatus() async {
    final response = await dio.get(UserCudAPI.backupStatusCheck);
    return response.data;
  }
  

  // 3. 데이터 복원 요청
  Future<String> requestRestore() async {
    final response = await dio.get(UserCudAPI.backupRestore);
    // 서버에서 JSON 문자열을 반환하므로 바로 처리
    return response.data;
  }
}