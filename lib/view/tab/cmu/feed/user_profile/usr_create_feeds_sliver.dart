import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/usrs_feed_list_request.dart';
import 'package:my_app/providers/api_feed_providers.dart';

class UsrCreateFeedsSliver extends ConsumerWidget {
  final int userId;
  const UsrCreateFeedsSliver({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFeeds = ref.watch(
      userCreateFeedsProvider(
        UsrsFeedQueryParams(userId: userId),
      ),
    );

    return asyncFeeds.when(
      data: (response) {
        final feeds = response.items;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final feed = feeds[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[${feed.category}] ${feed.title}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(feed.ctntPreview!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.thumb_up, size: 16),
                        const SizedBox(width: 4),
                        Text('${feed.likeCnt}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.comment, size: 16),
                        const SizedBox(width: 4),
                        Text('${feed.replyCnt}', style: const TextStyle(fontSize: 12)),
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
            childCount: feeds.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Text('오류 발생: $e')),
      ),
    );
  }
}
