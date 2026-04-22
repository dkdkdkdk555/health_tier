import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/model/usr/admin/feed_report_model.dart';
import 'package:my_app/model/usr/admin/reply_report_model.dart';
import 'package:my_app/model/usr/admin/report_action_request.dart' show ReportActionRequest;
import 'package:my_app/model/usr/auth/push_token_request.dart';
import 'package:my_app/model/usr/user/ht_user_block_dto.dart' show HtUserBlockDto;
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

  // 차단하기
  Future<String> blockUser(int blockUserId) async {
    final response = await dio.post(UserCudAPI.doBlock(blockUserId));
    if(response.statusCode == 200) {
      return response.data.toString();
    } else {
      throw Exception('차단하기 실패: ${response.statusCode}');
    }
  }

  // 차단해제
  Future<String> doBlockCancle(int blockedUserId) async {
    final response = await dio.delete(UserCudAPI.doBlockCancle(blockedUserId));
    if(response.statusCode == 200) {
      return response.data.toString();
    } else {
      throw Exception('차단해제 실패: ${response.statusCode}');
    }
  }

  // 차단 사용자 목록 조회
  Future<Result<List<HtUserBlockDto>>> getBlockedUsers() async {
    final response = await dio.get(UserAPI.getBlockedUsers,);
    return Result.fromJson(
      response.data,
      (obj) => (obj as List).map((e) => HtUserBlockDto.fromJson(e)).toList(),
    );
  }

  // 신고된 피드 목록 조회
  Future<Result<List<FeedReportModel>>> getReportedFeeds() async {
    final response = await dio.get(AdminAPI.reportedFeedList,);
    return Result.fromJson(
      response.data,
      (obj) => (obj as List).map((e) => FeedReportModel.fromJson(e)).toList(),
    );
  }

  // 신고된 댓글 목록 조회
  Future<Result<List<ReplyReportModel>>> getReportedReplies() async {
    final response = await dio.get(AdminAPI.reportedReplyList,);
    return Result.fromJson(
      response.data,
      (obj) => (obj as List).map((e) => ReplyReportModel.fromJson(e)).toList(),
    );
  }

  // 신고된 피드 처리 (유지 / 경고 / 삭제)
  Future<String> handleFeedReport(ReportActionRequest request) async {
    final response = await dio.post(
      AdminAPI.actionReportedFeed,
      data: request.toJson(),
    );
    if (response.statusCode == 200) {
      return response.data.toString();
    } else {
      throw Exception('피드 신고 처리 실패: ${response.statusCode}');
    }
  }

  // 신고된 댓글 처리 (유지 / 경고 / 삭제)
  Future<String> handleReplyReport(ReportActionRequest request) async {
    final response = await dio.post(
      AdminAPI.actionReportedReply,
      data: request.toJson(),
    );
    if (response.statusCode == 200) {
      return response.data.toString();
    } else {
      throw Exception('피드 신고 처리 실패: ${response.statusCode}');
    }
  }

  // 전환율 측정 api - 푸시 알림 클릭
  Future<void> switchPushNotification(String pushKey) async {
    await dio
        .post(UserDataAPI.switchPush, queryParameters: {'pushKey': pushKey});
  }

  // 전환율 측정 api - 기록이미 해서 푸시 알림 무시
  Future<void> ignorePushNotification(String pushKey) async {
    await dio
        .post(UserDataAPI.ignorePush, queryParameters: {'pushKey': pushKey});
  }
}