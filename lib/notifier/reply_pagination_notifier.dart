import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/service/feed_api_service.dart';

class ReplyPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<ReplyResponseDto>>> {
  final Ref _ref;
  final int cmuId;
  FeedService? _service;
  int? _cursorId;
  int? _cursorLikeCnt;
  int? _cursorReplyCount;
  bool _hasNext = true; // 다음 페이지가 있는지 여부

  int? get cursorId => _cursorId;

  ReplyPaginationNotifier(this._ref, this.cmuId)
      : super(const AsyncValue.loading()) {
    _initializeServiceAndFetch(); // 서비스 초기화 및 초기 데이터 로딩 시작
  }

  // 비동기적으로 FeedService를 초기화하고 초기 데이터를 불러오는 메서드
  Future<void> _initializeServiceAndFetch() async {
    try {
      // feedServiceAuth FutureProvider가 완료될 때까지 기다립니다.
      _service = await _ref.watch(feedServiceAuth.future);
      // 서비스 초기화 완료 후 초기 데이터 로딩
      await fetchInitial();
    } catch (e, st) {
      // 서비스 로딩 실패 또는 초기 데이터 로딩 실패 시 에러 처리
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchInitial() async {
    if (_service == null) {
      state = AsyncValue.error('FeedService is not initialized yet.', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final response = await _service!.getReplies(cmuId: cmuId);

      if (response.items.isEmpty) {
        _hasNext = false;
        state = AsyncValue.data(response); // 빈 리스트로 전달
        return;
      }

      _cursorId = response.lastCursorId;
      _cursorLikeCnt = response.items.last.likeCnt;
      _cursorReplyCount = response.items.last.children.length;
      _hasNext = response.hasNext;

      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> fetchNext() async {
     if (_service == null) {
      return;
    }
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
      final response = await _service!.getReplies(
        cmuId: cmuId,
        cursorId: _cursorId,
        cursorLikeCnt: _cursorLikeCnt,
        cursorReplyCount: _cursorReplyCount,
      );

      //  기존 데이터에 새 데이터를 이어붙여 상태 업데이트
      final combinedItems = [...currentState.items, ...response.items];

      if (response.items.isEmpty) {
        _hasNext = false;
        state = AsyncValue.data(ScrollResponse(
          items: combinedItems,
          lastCursorId: null,
          hasNext: _hasNext,
        ));
        return;
      }

      // 4. 커서 및 다음 페이지 여부 업데이트
      _cursorId = response.lastCursorId;
      _cursorLikeCnt = response.items.last.likeCnt;
      _cursorReplyCount = response.items.last.children.length;
      _hasNext = response.hasNext;      

      // `AsyncValue.data` 상태를 유지하며 새로운 `ScrollResponse` 객체로 업데이트.
      //    이것이 스크롤 위치 유지의 핵심입니다.
      state = AsyncValue.data(ScrollResponse(
        items: combinedItems,
        lastCursorId: _cursorId,
        hasNext: _hasNext,
        // isFetchingNext는 이제 ScrollResponse에 없으므로 여기에 포함시키지 않습니다.
      ));

    } catch (e, st) {
     state = AsyncValue<ScrollResponse<ReplyResponseDto>>.error(e, st).copyWithPrevious(state);
    }
  }

  // 새로운 댓글 추가 (댓글 또는 대댓글)
  void addReply(ReplyResponseDto newReply) {
    // 현재 데이터를 가져옵니다.
    final currentScrollResponse = state.asData?.value;
    if (currentScrollResponse == null) {
      // 데이터가 아직 로드되지 않았으면 처리하지 않습니다.
      return;
    }

    List<ReplyResponseDto> updatedItems = List.from(currentScrollResponse.items);

    if (newReply.parentReplyId == null) {
      // 새로운 댓글인 경우 (대댓글이 아닌 경우)
      // 최신 댓글을 목록의 가장 앞에 추가합니다.
      updatedItems.add(newReply);
    } else {
      // 새로운 대댓글인 경우
      // 해당 부모 댓글을 찾아 대댓글 목록에 추가합니다.
      int parentIndex = updatedItems.indexWhere((reply) => reply.id == newReply.parentReplyId);
      if (parentIndex != -1) {
        // 부모 댓글의 children 리스트를 복사하여 새 대댓글을 추가하고, 부모 댓글을 새 객체로 교체합니다.
        // 이는 불변성(immutability)을 유지하기 위함입니다.
        ReplyResponseDto parentReply = updatedItems[parentIndex];
        List<ReplyResponseDto> updatedChildren = List.from(parentReply.children);
        updatedChildren.add(newReply); // 대댓글은 보통 기존 대댓글 뒤에 추가됩니다.

        updatedItems[parentIndex] = parentReply.copyWith(children: updatedChildren);
      } else {
        // 부모 댓글을 찾을 수 없는 경우 (예: 부모 댓글이 현재 로드된 페이지에 없는 경우)
        debugPrint('부모 댓글을 찾을 수 없습니다: ${newReply.parentReplyId}');
        // 이 경우, API를 다시 호출하여 전체 목록을 갱신하는 것을 고려할 수 있으나,
        // 여기서는 간단히 무시하거나, 사용자에게 알림을 줄 수 있습니다.
        // 여기서는 그냥 무시하고 스크롤 위치를 유지하는 데 집중합니다.
        return;
      }
    }

    // 새로운 상태로 업데이트
    state = AsyncValue.data(currentScrollResponse.copyWith(items: updatedItems));
  }

  // 기존 댓글 수정 (댓글 또는 대댓글)
  void updateReply(ReplyResponseDto updatedReply) {
    // 현재 데이터를 가져옵니다.
    final currentScrollResponse = state.asData?.value;
    if (currentScrollResponse == null) {
      return;
    }

    List<ReplyResponseDto> updatedItems = List.from(currentScrollResponse.items);

    if (updatedReply.parentReplyId == null) {
      // 부모 댓글(일반 댓글)인 경우
      int index = updatedItems.indexWhere((reply) => reply.id == updatedReply.id);
      if (index != -1) {
        updatedItems[index] = updatedReply; // 해당 댓글 교체
      }
    } else {
      // 대댓글인 경우
      // 먼저 부모 댓글을 찾습니다.
      int parentIndex = updatedItems.indexWhere((reply) => reply.id == updatedReply.parentReplyId);
      if (parentIndex != -1) {
        ReplyResponseDto parentReply = updatedItems[parentIndex];
        List<ReplyResponseDto> updatedChildren = List.from(parentReply.children);
        
        // 부모 댓글의 children 목록에서 해당 대댓글을 찾아서 교체합니다.
        int childIndex = updatedChildren.indexWhere((child) => child.id == updatedReply.id);
        if (childIndex != -1) {
          updatedChildren[childIndex] = updatedReply;
          // 부모 댓글의 children 리스트를 새 리스트로 교체하여 부모 댓글 자체도 새 객체로 만듭니다.
          updatedItems[parentIndex] = parentReply.copyWith(children: updatedChildren);
        }
      }
    }

    // 새로운 상태로 업데이트
    state = AsyncValue.data(currentScrollResponse.copyWith(items: updatedItems));
  }
}