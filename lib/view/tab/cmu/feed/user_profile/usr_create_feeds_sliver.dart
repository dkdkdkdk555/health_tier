import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/usrs_feed_list_request.dart';
import 'package:my_app/providers/api_feed_providers.dart';

class UsrCreateFeedsSliver extends ConsumerStatefulWidget {
  final int userId;
  const UsrCreateFeedsSliver({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UsrCreateFeedsSliver> createState() => _UsrCreateFeedsSliverState();
}

class _UsrCreateFeedsSliverState extends ConsumerState<UsrCreateFeedsSliver> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(
      userCreateFeedsProvider(
        UsrsFeedQueryParams(userId: widget.userId),
      ).notifier,
    );

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      notifier.fetchNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncFeeds = ref.watch(
      userCreateFeedsProvider(
        UsrsFeedQueryParams(userId: widget.userId),
      ),
    );

    return asyncFeeds.when(
      data: (response) {
        final feeds = response.items;
        return ListView.builder(
          controller: _scrollController,
          itemCount: feeds.length,
          itemBuilder: (context, index) {
            final feed = feeds[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Title
                  Text(
                    '[${feed.category}] ${feed.title}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  // Preview Content
                  Text(
                    '${feed.ctntPreview}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  // Like, Reply, Date
                  Row(
                    children: [
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${feed.likeCnt}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${feed.replyCnt}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      const Spacer(),
                      Text(
                        feed.viewDttm,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류 발생: $e')),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
