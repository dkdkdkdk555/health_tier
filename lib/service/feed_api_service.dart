import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/category_model.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/model/cmu/feed/keyword_search_param.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/model/cmu/feed/user_info_response_dto.dart';
import 'package:my_app/model/cmu/feed/usrs_feed_list_request.dart';

class FeedService {
  final Dio dio;
  FeedService(this.dio);

  // 카테고리 조회
  Future<Result<List<Category>>> getCategories() async {
    final response = await dio.get(FeedAPI.getCategories);
    return Result.fromJson(
      response.data,
      (json) => (json as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList(),
    );
  }

  // 피드목록 조회
  Future<ScrollResponse<FeedPreviewDto>> getFeedList(FeedQueryParams feedQueryParams) async {
    final response = await dio.get(
      FeedAPI.getFeeds,
      queryParameters: {
        if (feedQueryParams.categoryId != null) 'categoryId': feedQueryParams.categoryId == 0 ? null : feedQueryParams.categoryId,
        if (feedQueryParams.hotYn != null) 'hotYn': feedQueryParams.hotYn,
        if (feedQueryParams.cursorId != null) 'cursorId': feedQueryParams.cursorId,
        'limit': feedQueryParams.limit,
      },
    );
    return ScrollResponse.fromJson(
      response.data,
      (json) => FeedPreviewDto.fromJson(json),
    );
  }

  // 새 피드 존재 여부 확인
  Future<bool> isThereNewFeed({
    required int latestId,
    int? categoryId,
  }) async {
    final response = await dio.get(
      FeedAPI.isThereNewFeed,
      queryParameters: {
        'latestId': latestId,
        if (categoryId != null && categoryId != 0) 'category': categoryId,
      },
    );
    debugPrint(response.data.toString());
    return response.data.toString() == 'Y';
  }

  // 피드 상세 조회
  Future<Result<FeedDetailDto>> getFeedDetail(int id, int? userId) async{
    final response = await dio.get('${FeedAPI.getFeed}/$id',
      queryParameters: {
        if(userId != null) 'userId' : userId
      }
    );
    return Result.fromJson(
      response.data,
      (json) => FeedDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  // 피드 댓글 조회
  Future<ScrollResponse<ReplyResponseDto>> getReplies({
    required int cmuId,
    int? cursorId,
    int? cursorLikeCnt,
    int? cursorReplyCount,
    int limit = 5,
  }) async {
    final response = await dio.get(
      '${FeedAPI.getReplies}/$cmuId',
      queryParameters: {
        if (cursorId != null) 'cursorId': cursorId,
        if (cursorLikeCnt != null) 'cursorLikeCnt': cursorLikeCnt,
        if (cursorReplyCount != null) 'cursorReplyCount': cursorReplyCount,
        'limit': limit,
      },
    );
    return ScrollResponse.fromJson(
      response.data,
      (json) => ReplyResponseDto.fromJson(json),
    );
  }

  // 피드 상세 - 같은 카테고리의 다른 글(인기순) 가져오기
  Future<ScrollResponse<FeedPreviewDto>> getSameCategoryFeedList(FeedQueryParams feedQueryParams) async {
    final response = await dio.get(
      FeedAPI.getSameCategoryFeeds,
      queryParameters: {
        if (feedQueryParams.categoryId != null) 'categoryId': feedQueryParams.categoryId == 0 ? null : feedQueryParams.categoryId,
        if (feedQueryParams.cursorId != null) 'cursorId': feedQueryParams.cursorId,
        'limit': 5,// feedQueryParams.limit,
      },
    );
    return ScrollResponse.fromJson(
      response.data,
      (json) => FeedPreviewDto.fromJson(json),
    );
  }

  // 사용자 작성 피드 목록 조회
  Future<ScrollResponse<FeedPreviewDto>> getUserFeeds(UsrsFeedQueryParams usrsFeedQueryParams) async {
    final response = await dio.get(
      '${FeedAPI.getUsersFeeds}/${usrsFeedQueryParams.userId}',
      queryParameters: {
        if (usrsFeedQueryParams.cursorId != null) 'cursorId': usrsFeedQueryParams.cursorId,
        'limit': usrsFeedQueryParams.limit,
      },
    );
    return ScrollResponse.fromJson(
      response.data,
      (json) => FeedPreviewDto.fromJson(json),
    );
  }

  // 사용자 정보 조회
  Future<UserInfoResponseDto> getUserInfo(int userId) async {
    if (userId == 0) {
      throw Exception("유효하지 않은 사용자 ID입니다.");
    }
    final response = await dio.get('${UserAPI.getUserInfo}/$userId');
    return UserInfoResponseDto.fromJson(response.data);
  }

  // 통합검색
  Future<ScrollResponse<FeedPreviewDto>> getFeedsByKeyword(KeywordSearchParam searchParam) async {
    final response = await dio.get(
      FeedAPI.search,
      queryParameters: {
        'keyword': searchParam.keyword,
        if (searchParam.cursorId != null) 'cursorId': searchParam.cursorId,
        'limit': searchParam.limit,
      },
    );
    return ScrollResponse.fromJson(
      response.data,
      (json) => FeedPreviewDto.fromJson(json),
    );
  }
  
  // 조회수증가
  Future<String> increaseView(int feedId) async {
    try {
      final response = await dio.post(
        FeedAPI.increaseViewCount(feedId),
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        debugPrint('조회수 증가 요청 실패: ${response.statusCode}');
        throw Exception(response.statusCode);
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? '조회수 증가 요청 실패';
      throw Exception(message);
    } catch (e) {
      throw Exception('알 수 없는 조회수 증가 요청 에러: $e');
    }
  }
}