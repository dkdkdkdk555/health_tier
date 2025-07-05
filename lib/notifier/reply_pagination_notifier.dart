import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/service/feed_service.dart';

class ReplyPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<ReplyResponseDto>>> {
  final FeedService service;
  final int cmuId;
  int? _cursorId;
  bool _hasNext = true;

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
    if (!_hasNext) return;
    try {
      final currentState = state;
      state = const AsyncValue.loading(); // optional: 로딩 인디케이터 표시 목적

      final response = await service.getReplies(
        cmuId: cmuId,
        cursorId: _cursorId,
      );

      _cursorId = response.lastCursorId;
      _hasNext = response.hasNext;

      // 기존 리스트에 이어붙임
      if (currentState is AsyncData<ScrollResponse<ReplyResponseDto>>) {
        final prevItems = currentState.value.items;
        final combinedItems = [...prevItems, ...response.items];
        state = AsyncValue.data(ScrollResponse(
          items: combinedItems,
          lastCursorId: _cursorId,
          hasNext: _hasNext,
        ));
      } else {
        state = AsyncValue.data(response);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
