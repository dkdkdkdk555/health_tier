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
  
}