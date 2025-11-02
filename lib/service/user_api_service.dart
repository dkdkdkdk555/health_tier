import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/model/usr/auth/push_token_request.dart';
import 'package:my_app/model/usr/user/usr_leave_request.dart';
import 'package:my_app/model/usr/user/usr_simple_dto.dart';
import 'package:my_app/model/usr/user/weight_3_info.dart';
import 'package:my_app/util/token_manager.dart';

class UserApiService {

  final Dio dio;
  UserApiService(this.dio);

  // 사용자 뱃지 조회
  Future<Result<List<BadgeInfoDto>>> getUserBadges() async {
    final response = await dio.get(UserCudAPI.getUserBadges);
    return Result.fromJson(
      response.data,
      (obj) => (obj as List).map((e) => BadgeInfoDto.fromJson(e)).toList(),
    );
  }

  // 사용자 3대운동 중량 조회
  Future<Result<List<Weight3Info>>> getUserInfoWeight() async {
    final response = await dio.get(UserCudAPI.getUsrInfoWeight);
    return Result.fromJson(
      response.data,
      (obj) => (obj as List).map((e) => Weight3Info.fromJson(e)).toList()
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

  // 내정보관리 - 유저정보 가져오기
  Future<Result<UserSimpleDto>> getUserSimpleInfo() async {
    final token = await TokenManager.getAccessToken();
    if (token == null || token.isEmpty) {
      // 로그아웃 이후 호출 차단
      throw DioException(
        requestOptions: RequestOptions(path: UserCudAPI.getUserInfoSimple),
        message: 'Access token is missing, skipping request.',
        type: DioExceptionType.cancel,
      );
    }

    final response = await dio.get(UserCudAPI.getUserInfoSimple);
    return Result.fromJson(
      response.data, 
      (json) => UserSimpleDto.fromJson(json as Map<String, dynamic>),
    );
  }

  // 내정보관리 - 닉네임 변경
  Future<String> updateNickname(String newNickname) async {
    final response = await dio.post(
      UserCudAPI.updateUserNickname,
      queryParameters: {'nickname': newNickname},
    );
    return response.data;
  }

  // 내정보관리 - 프로필 이미지 등록/수정
  Future<String> createOrUpdateProfileImage({
    required String imagePath,
  }) async {
    final formData = FormData.fromMap({
      'image': imagePath
    });

    final response = await dio.post(
      UserCudAPI.createOrUpdateProfileImage,
      data: formData,
    );

    return response.data;
  }

  // 내정보관리 - 프로필 이미지 삭제
  Future<String> deleteProfileImage() async {
    final response = await dio.delete(
      UserCudAPI.deleteProfileImage,
    );
    return response.data;
  }

  // 회원 탈퇴
  Future<String> leaveUser(UsrLeaveRequest request) async {
    final response = await dio.post(
      UserCudAPI.userLeaveOut,
      data: request.toJson(),
    );
    return response.data;
  }

  // 내정보관리 - FCM 푸시 토큰 등록/수정
  Future<String> registerPushToken(PushTokenRequest request) async {
    final response = await dio.post(
      UserCudAPI.fcmInfoSave,
      data: request.toJson(),
    );
    return response.data;
  }


}