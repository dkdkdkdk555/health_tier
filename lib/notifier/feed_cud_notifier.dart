import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/feed_cud_dto.dart';
import 'package:my_app/model/cmu/feed/feed_cud_result.dart';
import 'package:my_app/providers/feed_auth_providers.dart';

class FeedCudNotifier extends AsyncNotifier<FeedCudResult?> {
  @override
  Future<FeedCudResult?> build() async {
    // Notifier가 처음 빌드될 때 초기 상태.
    // 글을 생성/수정하는 것이므로 초기 상태는 null
    return null;
  }

  // 게시글 저장 (생성 또는 수정) 메서드
  Future<void> saveFeed(FeedDto dto) async {
    state = const AsyncLoading(); // 저장/수정 시작: 로딩 상태로 변경

    try {
      final feedService = ref.read(feedCudService); // FeedCudService 인스턴스 가져오기

      if (dto.id != null) {
        // FeedDto의 'id' 필드가 존재하면 수정 API 호출
        await feedService.updateFeed(dto);
        state = AsyncData(FeedCudResult(
          type: FeedCudType.update,
          feedId: dto.id, // 수정 시에는 원래 DTO의 ID를 사용
          message: '게시글이 성공적으로 수정되었습니다.',
        ));
      } else {
        // FeedDto의 'id' 필드가 없으면 생성 API 호출
        final newFeedId = await feedService.createFeed(dto);
        state = AsyncData(FeedCudResult(
          type: FeedCudType.create,
          feedId: newFeedId, // 생성 시에는 새로 받은 ID를 사용
          message: '게시글이 성공적으로 등록되었습니다.',
        ));
      }
    } catch (e, st) {
      // 에러 발생 시 AsyncError 상태로 변경
      state = AsyncError(e, st);
    }
  }

  // 상태를 초기화하는 메서드 (필요시)
  void resetState() {
    state = const AsyncData(null); // 상태를 초기 데이터(null)로 리셋
  }
}

// AsyncNotifierProvider 정의
final feedCudNotifierProvider = AsyncNotifierProvider<FeedCudNotifier, FeedCudResult?>(() {
  return FeedCudNotifier();
});