import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/service/feed_service.dart';

class FeedPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<FeedPreviewDto>>>{
  final FeedService _service;
  
  bool _isFetching = false;
  bool _hasNext = true;
  late FeedQueryParams _params;
  List<FeedPreviewDto> _feeds = [];

  FeedPaginationNotifier(this._service, FeedQueryParams params) : super(const AsyncLoading()) {
    _params = FeedQueryParams(
      categoryId: params.categoryId,
      hotYn:  params.hotYn,
      cursorId: params.cursorId,
      limit: params.limit
    );
  }

  Future<void> fetchInitial() async {
    state = const AsyncLoading();

    // 최초 요청 시 cursorId는 null
    _params.cursorId = null;

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
    if(_isFetching || !_hasNext) return;
    _isFetching = true;
    
    debugPrint('커서 : ${_params.cursorId}');

    try{
      final response = await _service.getFeedList(_params);
      _feeds.addAll(response.feeds);
      _params.cursorId = response.lastCursorId;
      _hasNext = response.hasNext;
      state = AsyncData(ScrollResponse(feeds: _feeds, lastCursorId: _params.cursorId, hasNext: _hasNext));
    } finally {
      _isFetching = false;
    }
  }

}