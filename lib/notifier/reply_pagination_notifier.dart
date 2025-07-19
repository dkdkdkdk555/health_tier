import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/service/feed_api_service.dart';

class ReplyPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<ReplyResponseDto>>> {
  final FeedService service;
  final int cmuId;
  int? _cursorId;
  bool _hasNext = true; // 다음 페이지가 있는지 여부

  ReplyPaginationNotifier(this.service, this.cmuId)
      : super(const AsyncValue.loading()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = const AsyncValue.loading();
    try {
      final response = await service.getReplies(cmuId: cmuId);
      _cursorId = response.lastCursorId;
      _hasNext = response.hasNext;
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchNext() async {
    // 1. 다음 페이지가 없거나, 현재 이미 로딩 중이라면 아무것도 하지 않음.
    //    `isLoading`은 `AsyncValue.loading()` 상태일 때만 true이므로,
    //    만약 기존 데이터를 유지하며 로딩 중임을 나타내고 싶다면,
    //    다른 플래그(예: `_isFetchingMore`)가 필요합니다.
    //    하지만 `isFetchingNext`를 사용하지 않기로 했으므로,
    //    여기서는 `state.isLoading`이 `fetchInitial`에 의해 true일 때만 막습니다.
    //    만약 fetchNext 호출 시에도 로딩 인디케이터를 보여주고 싶다면
    //    아래에서 state.copyWith로 AsyncData를 유지하며 처리합니다.
    if (!_hasNext || state.isLoading) { // `state.isLoading`으로 초기 로딩과 중복 호출 방지
      // 만약 `fetchNext` 호출 중에도 버튼 자리에 로딩 인디케이터를 보여주고 싶다면
      // `_isLoadingMore`와 같은 내부 플래그를 Notifier에 두어야 합니다.
      // 여기서는 `isFetchingNext`를 사용하지 않기로 했으니, 이 조건은 초기 로딩에 주로 관여합니다.
      return;
    }

    // 2. 현재 로딩 중임을 나타내는 임시 상태 (선택 사항)
    //    이 부분을 넣으면 기존 댓글이 잠시 사라질 수 있습니다.
    //    스크롤 위치 유지를 위해 이 부분을 생략하거나, AsyncData를 유지하며 로딩 플래그를 전달해야 합니다.
    //    여기서는 스크롤 유지가 목적이므로, AsyncData를 유지합니다.

    final currentState = state.asData?.value; // 현재 데이터 스냅샷
    if (currentState == null) {
      // 데이터가 아직 로드되지 않은 상태라면 (예: 초기 로딩 실패 등) fetchNext를 실행하지 않음
      return;
    }

    try {
      // 3. API 호출
      final response = await service.getReplies(
        cmuId: cmuId,
        cursorId: _cursorId,
      );

      // 4. 커서 및 다음 페이지 여부 업데이트
      _cursorId = response.lastCursorId;
      _hasNext = response.hasNext;

      // 5. 기존 데이터에 새 데이터를 이어붙여 상태 업데이트
      final combinedItems = [...currentState.items, ...response.items];

      // ✅ `AsyncValue.data` 상태를 유지하며 새로운 `ScrollResponse` 객체로 업데이트.
      //    이것이 스크롤 위치 유지의 핵심입니다.
      state = AsyncValue.data(ScrollResponse(
        items: combinedItems,
        lastCursorId: _cursorId,
        hasNext: _hasNext,
        // isFetchingNext는 이제 ScrollResponse에 없으므로 여기에 포함시키지 않습니다.
      ));

    } catch (e, st) {
      // 에러 발생 시, 현재 데이터를 유지하면서 에러 상태로 변경 (선택 사항)
      // 또는 그냥 에러 상태로 전체 전환할 수도 있습니다.
      state = AsyncValue.error(e, st);
    }
  }
}