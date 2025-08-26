import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/usrs_feed_list_request.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/usr_create_feed_item.dart';

class MyWroteFeed extends ConsumerStatefulWidget {
  const MyWroteFeed({super.key});

  @override
  ConsumerState<MyWroteFeed> createState() => _MyWroteFeedState();
}

class _MyWroteFeedState extends ConsumerState<MyWroteFeed> {
  final ScrollController _scrollController = ScrollController();

  late final UsrsFeedQueryParams _initialParams;
  int? _myUserId;

  @override
  void initState() {
    super.initState();
    _loadMyUserId();
    _initialParams = UsrsFeedQueryParams(userId: _myUserId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userCreateFeedsProvider(_initialParams).notifier).fetchInitial();
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadMyUserId() async {
    _myUserId = UserPrefs.myUserId;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier =
          ref.read(userCreateFeedsProvider(_initialParams).notifier);
      notifier.fetchNext();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncFeeds = ref.watch(userCreateFeedsProvider(_initialParams));

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _buildHeader('내가 쓴 글'),
          Container(
            height: 2,
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
          ),
          asyncFeeds.when(
            data: (data) {
              final items = data.items;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      '작성한 글이 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // ✅ SliverList 안에서 또 SliverList 쓸 수 없음 → 대신 children으로 변환
              return Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: UsrCreateFeedItem(feed: items[i]),
                    ),
                    Container(
                      height: 1,
                      decoration:
                          const BoxDecoration(color: Color(0xFFEEEEEE)),
                    ),
                  ],
                  if (data.hasNext)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) {
              debugPrint('Error fetching user feeds: $error');
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text('데이터 로딩 중 오류가 발생했습니다: $error'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      height: 86,
      padding: const EdgeInsets.only(
        top: 48,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Pretendard',
              height: 0.07,
            ),
          ),
        ],
      ),
    );
  }
}
