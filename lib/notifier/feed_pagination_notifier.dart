import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/service/feed_service.dart';

class FeedPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<FeedPreviewDto>>> {
  final FeedService _service;
  final FeedQueryParams _params;

  bool _isFetching = false;
  bool _hasNext = true;
  List<FeedPreviewDto> _feeds = [];

  FeedPaginationNotifier(this._service, this._params) : super(const AsyncLoading()) {
    _fetchInitial(); // 생성 시 자동 실행
  }

  Future<void> _fetchInitial() async {
    state = const AsyncLoading();

    try {
      final response = await _service.getFeedList(_params);
      _feeds = response.feeds;
      _hasNext = response.hasNext;
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> fetchNext() async {
    if (_isFetching || !_hasNext) return;
    _isFetching = true;

    try {
      final response = await _service.getFeedList(_params.copyWith(cursorId: _params.cursorId));
      _feeds.addAll(response.feeds);
      _params.cursorId = response.lastCursorId;
      _hasNext = response.hasNext;
      state = AsyncData(ScrollResponse(
        feeds: _feeds,
        lastCursorId: _params.cursorId,
        hasNext: _hasNext,
      ));
    } finally {
      _isFetching = false;
    }
  }
}

