
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/model/cmu/feed/image_upload_args.dart';
import 'package:my_app/service/doc_api_service.dart' show DocApiService;
import 'package:my_app/service/feed_cud_api_service.dart';
import 'package:my_app/service/s3_api_service.dart' show S3ApiService;

// 토큰 정보를 헤더에 둔 요청객체
final authDioProvider = FutureProvider<Dio>((ref){
  return DIOConfig().createAuthDio(ref);
});

// FeedCudService도 FutureProvider로 변경 (가장 권장되는 방식)
final feedCudServiceProvider = FutureProvider<FeedCudService>((ref) async {
  // authDioProvider가 제공하는 Dio 인스턴스가 준비될 때까지 기다립니다.
  final dio = await ref.watch(authDioProvider.future);
  return FeedCudService(dio);
});
final docApiServiceProvider = FutureProvider<DocApiService>((ref) async {
  // authDioProvider가 제공하는 Dio 인스턴스가 준비될 때까지 기다립니다.
  final dio = await ref.watch(authDioProvider.future);
  return DocApiService(dio);
});


final s3ApiServiceProvider = FutureProvider<S3ApiService>((ref) async {
  // authDioProvider가 제공하는 Dio 인스턴스가 준비될 때까지 기다립니다.
  final dio = await ref.watch(authDioProvider.future);
  return S3ApiService(dio);
});

// 수정하기 피드상세조회
final feedDetailProviderForUpdate = FutureProvider.autoDispose.family<Result<FeedDetailDto>, int>((ref, feedId) async {
  // feedCudServiceProvider가 준비될 때까지 기다립니다.
  final service = await ref.watch(feedCudServiceProvider.future);
  return await service.getFeedDetail(feedId);
});

// 업로드된 이미지 url들
// final imageUploadProvider = FutureProvider.family<Result<List<String>>, ImageUploadArgs>((ref, args) async {
//   // feedCudServiceProvider가 준비될 때까지 기다립니다.
//   final service = await ref.watch(feedCudServiceProvider.future);
//   return await service.uploadImages(
//     images: args.images,
//     deleteUrls: args.deleteUrls,
//   );
// });

final s3PresignedProvider = FutureProvider.autoDispose.family<List<String>,
    ({
      String folder,
      List<Map<String, String>> files,
      List<String>? deleteUrls,
    })>((ref, args) async {
  final s3Service = await ref.watch(s3ApiServiceProvider.future);

    final response = await s3Service.getPresignedUrls(
      folder: args.folder,
      files: args.files,
      deleteUrls: args.deleteUrls,
    );

    return response;
});