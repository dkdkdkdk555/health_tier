
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/model/cmu/feed/image_upload_args.dart';
import 'package:my_app/service/feed_cud_api_service.dart';

// 토큰 정보를 헤더에 둔 요청객체
final authDioProvider = FutureProvider<Dio>((ref){
  return DIOConfig().createAuthDio();
});

// FeedCudService도 FutureProvider로 변경 (가장 권장되는 방식)
final feedCudServiceProvider = FutureProvider<FeedCudService>((ref) async {
  // authDioProvider가 제공하는 Dio 인스턴스가 준비될 때까지 기다립니다.
  final dio = await ref.watch(authDioProvider.future);
  return FeedCudService(dio);
});

// 수정하기 피드상세조회
final feedDetailProviderForUpdate = FutureProvider.family<Result<FeedDetailDto>, int>((ref, feedId) async {
  // feedCudServiceProvider가 준비될 때까지 기다립니다.
  final service = await ref.watch(feedCudServiceProvider.future);
  return await service.getFeedDetail(feedId);
});

// 업로드된 이미지 url들
final imageUploadProvider = FutureProvider.family<Result<List<String>>, ImageUploadArgs>((ref, args) async {
  // feedCudServiceProvider가 준비될 때까지 기다립니다.
  final service = await ref.watch(feedCudServiceProvider.future);
  return await service.uploadImages(
    images: args.images,
    deleteUrls: args.deleteUrls,
  );
});