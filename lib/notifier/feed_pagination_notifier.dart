import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/providers/api_feed_providers.dart';
import 'package:my_app/service/feed_service.dart';

class FeedPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<FeedPreviewDto>>>{
  final FeedService _service;
  
  FeedPaginationNotifier(this._service) : super(const AsyncLoading()){
    fetchInitial();
  }

  bool _isFetching = false;
  bool _hasNext = true;
  late int _lastCursorId;

  List<FeedPreviewDto> _feeds = [];

  Future<void> fetchInitial() async {
    state = const AsyncLoading();
    try {
      final response = await _service.getFeedList(FeedQueryParams());
      _feeds = response.feeds;
      _lastCursorId = response.lastCursorId;
      _hasNext = response.hasNext;
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> fetchNext() async {
    if(_isFetching || !_hasNext) return;
    _isFetching = true;

    try{
      final response = await _service.getFeedList(
        FeedQueryParams(cursorId: _lastCursorId),
      );
      _feeds.addAll(response.feeds);
      _lastCursorId = response.lastCursorId;
      _hasNext = response.hasNext;
      state = AsyncData(ScrollResponse(feeds: _feeds, lastCursorId: _lastCursorId, hasNext: _hasNext));
    } finally {
      _isFetching = false;
    }
  }

}

// stateNotifier provider
final feedPaginationProvider = StateNotifierProvider<FeedPaginationNotifier, AsyncValue<ScrollResponse<FeedPreviewDto>>>(
  (ref) => FeedPaginationNotifier(ref.watch(feedService)),
);
