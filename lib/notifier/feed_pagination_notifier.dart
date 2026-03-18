import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/service/feed_api_service.dart';

class FeedPaginationNotifier extends StateNotifier<AsyncValue<ScrollResponse<FeedPreviewDto>>> {
  final FeedService _service;
  final FeedQueryParams _params;

  bool _isFetching = false;
  bool _hasNext = false; /*
    FeedListSliver 위젯 build 메서드에서
    final params = ref.watch(feedParamsProvider);
    final scrollResponse = ref.watch(feedPaginationProvider(params));
    params 바뀌면서 feedPaginationProvider가 새로운 인스턴스로 평가됨.
    이때 목록이 짧아 바닥에 약간의 스크롤로 바닥에 도달하면 fetchNext가 실행됨(이전 feedPaginationProvider 인스턴스에서 실행되는듯?)
    이때 _hasNext의 기본값을 true로 초기화 해뒀으면
    그럼 fetchInitial로 인해 _hasNext = false로 바뀌기 전에 fetchNext가 호출되므로
    fetchNext로 인해 랜더링된 목록 + AsyncData(response) 의 목록(fetchInital 시 _feeds를 리턴하지 않으므로)
    이 랜더링되어 아이템들이 중복돼 나타나는거임
   */
  List<FeedPreviewDto> _feeds = [];

  FeedPaginationNotifier(this._service, this._params) : super(const AsyncLoading()) {
    fetchInitial(); // 생성 시 자동 실행
  }

  Future<void> fetchInitial() async {
    _isFetching = true;
    state = const AsyncLoading();

    try {
      final response = await _service.getFeedList(_params);
      _feeds.clear();
      _feeds = response.items;
      _hasNext = response.hasNext;
      _params.cursorId = response.lastCursorId;
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _isFetching = false;
    }
  } 

  Future<void> fetchNext() async {
    if (_isFetching || !_hasNext) return;
    _isFetching = true;

    try {
      final response = await _service.getFeedList(_params.copyWith(cursorId: _params.cursorId));
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

  // 피드 삭제 시 목록에서 제거
  void removeFeed(int feedId) {
    _feeds.removeWhere((feed) => feed.id == feedId);
    state = AsyncData(ScrollResponse(
      items: List.from(_feeds), // 새로운 리스트로 감싸줘야 리빌드 잘 됨
      lastCursorId: _params.cursorId,
      hasNext: _hasNext,
    ));
  }
}

