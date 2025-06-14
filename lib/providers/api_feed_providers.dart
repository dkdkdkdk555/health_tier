import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/category_model.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/notifier/feed_pagination_notifier.dart';
import 'package:my_app/service/feed_service.dart';

// Dio 프로바이더를 전역으로 관리
final dioProvider = Provider<Dio>((ref){
  return DIOConfig().createNoneAuthDio();
});

// 서비스 객체 의존성 주입 받아 사용
final feedService = Provider<FeedService>((ref) {
  final dio = ref.watch(dioProvider);
  return FeedService(dio);
});

final getFeedCategories = FutureProvider<Result<List<Category>>>((ref) async {
  final service = ref.watch(feedService);
  return service.getCategories();
});

// stateNotifier provider
final feedPaginationProvider = StateNotifierProvider.family<FeedPaginationNotifier, AsyncValue<ScrollResponse<FeedPreviewDto>>, FeedQueryParams>((ref, params) {
  final service = ref.watch(feedService);
  return FeedPaginationNotifier(service, params);
});

