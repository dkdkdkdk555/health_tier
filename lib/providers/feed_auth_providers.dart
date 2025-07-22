
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/model/cmu/feed/image_upload_args.dart';
import 'package:my_app/service/feed_cud_api_service.dart';

// 토큰 정보를 헤더에 둔 요청객체
final authDioProvider = FutureProvider<Dio>((ref){
  return DIOConfig().createAuthDio('application/json');
});

final feedCudService = Provider<FeedCudService>((ref){
  // authDioProvider를 watch하여 AsyncValue<Dio>를 얻습니다.
  final authDioAsyncValue = ref.watch(authDioProvider);

  // AsyncValue의 상태에 따라 분기 처리합니다.
  return authDioAsyncValue.when(
    data: (dio) {
      // Dio 인스턴스가 성공적으로 로드되었을 때 FeedCudService를 반환합니다.
      return FeedCudService(dio);
    },
    loading: () {
      // Dio 인스턴스가 아직 로딩 중일 때.
      // 서비스 생성이 완료될 때까지 기다려야 하므로,
      // 이 경우 의존성 주입이 필요한 서비스에서는 일반적으로 오류를 던지는 것이 좋습니다.
      // UI에서는 이 Provider를 직접 watch하여 loading 상태를 처리해야 합니다.
      throw Exception('인증된 Dio 인스턴스가 아직 로딩 중입니다. FeedCudService를 사용할 수 없습니다.');
    },
    error: (error, stackTrace) {
      // Dio 인스턴스를 로드하는 도중 오류가 발생했을 때.
      // 이 경우에도 서비스 생성을 할 수 없으므로 오류를 던집니다.
      throw Exception('인증된 Dio 인스턴스를 로드하는 중 오류가 발생했습니다: $error');
    },
  );
});

// 수정하기 피드상세조회
final feedDetailProviderForUpdate = FutureProvider.family<Result<FeedDetailDto>, int>((ref, feedId) async {
  final service = ref.watch(feedCudService);
  return await service.getFeedDetail(feedId);
});

// 업로드된 이미지 url들
final imageUploadProvider = FutureProvider.family<Result<List<String>>, ImageUploadArgs>((ref, args) async {
  final service = ref.watch(feedCudService);
  return await service.uploadImages(
    images: args.images,
    deleteUrls: args.deleteUrls,
  );
});