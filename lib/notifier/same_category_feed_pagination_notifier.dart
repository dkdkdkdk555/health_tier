import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/service/feed_service.dart';

class SameCategoryFeedPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<FeedPreviewDto>>> {
  final FeedService _service;
  final FeedQueryParams _params;

  bool _isFetching = false;
  bool _hasNext = true;
  List<FeedPreviewDto> _feeds = [];

  SameCategoryFeedPaginationNotifier(this._service, this._params) : super(const AsyncLoading()) {
    fetchInitial(); // 생성 시 자동 실행
  }

  Future<void> fetchInitial() async {
    state = const AsyncLoading();

    try {
      final response = await _service.getSameCategoryFeedList(_params);
      _feeds.clear();
      _feeds = response.items;
      _hasNext = response.hasNext;
      _params.cursorId = response.lastCursorId;
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> fetchNext() async {
    if (_isFetching || !_hasNext) return;
    _isFetching = true;

    try {
      final response = await _service.getSameCategoryFeedList(_params.copyWith(cursorId: _params.cursorId));
      _feeds.addAll(response.items);
      _params.cursorId = response.lastCursorId;
      _hasNext = response.hasNext;
      state = AsyncData(ScrollResponse(
        items: _feeds,
        lastCursorId: _params.cursorId,
        hasNext: _hasNext,
      ));
    } finally {
      _isFetching = false;
    }
  }
}

