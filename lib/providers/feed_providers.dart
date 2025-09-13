import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
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
import 'package:my_app/notifier/feed_main_change_notifier.dart';
import 'package:my_app/notifier/feed_pagination_notifier.dart';
import 'package:my_app/notifier/reply_pagination_notifier.dart';
import 'package:my_app/notifier/same_category_feed_pagination_notifier.dart';
import 'package:my_app/notifier/search_result_feed_pagination_notifier.dart';
import 'package:my_app/notifier/user_create_feed_pagination_notifier.dart';
import 'package:my_app/service/feed_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Dio 프로바이더를 전역으로 관리
final dioProvider = Provider<Dio>((ref){
  return DIOConfig().createNoneAuthDio();
});

// Dio 프로바이더를 전역으로 관리
final dioAuthProvider = FutureProvider<Dio>((ref){
  return DIOConfig().createAuthDio(ref);
});

// 서비스 객체 의존성 주입 받아 사용
final feedService = Provider<FeedService>((ref) {
  final dio = ref.watch(dioProvider);
  return FeedService(dio);
});

// 서비스 객체 의존성 주입 받아 사용
final feedServiceAuth = FutureProvider<FeedService>((ref) async{
  final dio = await ref.watch(dioAuthProvider.future);
  return FeedService(dio);
});

final getFeedCategories = FutureProvider<Result<List<Category>>>((ref) async {
  final service = ref.watch(feedService);
  return service.getCategories();
});

// 피드목록 stateNotifier provider
final feedPaginationProvider = StateNotifierProvider.family<FeedPaginationNotifier, AsyncValue<ScrollResponse<FeedPreviewDto>>, FeedQueryParams>((ref, params) {
  final service = ref.watch(feedService);
  return FeedPaginationNotifier(service, params);
});

final feedParamsProvider = StateProvider<FeedQueryParams>((ref) {
  return FeedQueryParams();
});

// 피드 상세 조회 프로바이더
final feedDetailProvider = FutureProvider.autoDispose.family<Result<FeedDetailDto>, int>((ref, feedId) async {
  final service = await ref.watch(feedServiceAuth.future);
  final prefs = await SharedPreferences.getInstance();
  return await service.getFeedDetail(feedId, prefs.getInt('userId'));
});

// 피드 상세 댓글 조회 프로바이더
final replyPaginationProvider = StateNotifierProvider.family
    <ReplyPaginationNotifier, AsyncValue<ScrollResponse<ReplyResponseDto>>, int>((ref, cmuId) {
  return ReplyPaginationNotifier(ref, cmuId);
});

// 피드상세 - 같은카테고리의 피드목록 
final sameCategoryFeedPaginationProvider = StateNotifierProvider.family<SameCategoryFeedPaginationNotifier, AsyncValue<ScrollResponse<FeedPreviewDto>>, FeedQueryParams>((ref, params) {
  final service = ref.watch(feedService);
  return SameCategoryFeedPaginationNotifier(service, params);
});

// 사용자 프로필 - 사용자 정보
final userInfoProvider = FutureProvider.family<UserInfoResponseDto, int>((ref, userId) async {
  final service = ref.watch(feedService);
  return service.getUserInfo(userId);
});

// 사용자 프로필 - 사용자 작성 피드목록 조회
final userCreateFeedsProvider = StateNotifierProvider.family<UserCreateFeedPaginationNotifier, AsyncValue<ScrollResponse<FeedPreviewDto>>, UsrsFeedQueryParams>((ref, params) {
  final service = ref.watch(feedService);
  return UserCreateFeedPaginationNotifier(service, params);
});

// 통합검색
final searchFeedsProvider = StateNotifierProvider.autoDispose.family<SearchResultFeedPaginationNotifier, AsyncValue<ScrollResponse<FeedPreviewDto>>, String>((ref, keyword) {
  final service = ref.watch(feedService);
  final params = KeywordSearchParam(keyword: keyword);
  return SearchResultFeedPaginationNotifier(service, params);
});