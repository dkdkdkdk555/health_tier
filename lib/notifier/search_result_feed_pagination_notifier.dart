import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/keyword_search_param.dart';
import 'package:my_app/service/feed_service.dart';

class SearchResultFeedPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<FeedPreviewDto>>> {
  final FeedService _service;
  late KeywordSearchParam _params;

  bool _isFetching = false;
  bool _hasNext = true;
  List<FeedPreviewDto> _feeds = [];

  SearchResultFeedPaginationNotifier(this._service, KeywordSearchParam initialParams)
      : super(const AsyncLoading()) {
    _params = initialParams;
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = const AsyncLoading();
    _feeds.clear();
    _hasNext = true;

    try {
      final response = await _service.getFeedsByKeyword(_params);
      _feeds = response.items;
      _hasNext = response.hasNext;
      _params = _params.copyWith(cursorId: response.lastCursorId);

      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> fetchNext() async {
    if (_isFetching || !_hasNext) return;
    _isFetching = true;

    try {
      final nextParams = _params.copyWith(cursorId: _params.cursorId);
      final response = await _service.getFeedsByKeyword(nextParams);

      _feeds.addAll(response.items);
      _params = _params.copyWith(cursorId: response.lastCursorId);
      _hasNext = response.hasNext;

      state = AsyncData(ScrollResponse(
        items: _feeds,
        lastCursorId: _params.cursorId,
        hasNext: _hasNext,
      ));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _isFetching = false;
    }
  }
}
