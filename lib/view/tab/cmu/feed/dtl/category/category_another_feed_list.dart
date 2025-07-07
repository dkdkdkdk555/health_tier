import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/api_feed_providers.dart';

class CategoryAnotherFeedList extends ConsumerWidget {
  const CategoryAnotherFeedList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedCategoryId = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.categoryId));

    return const Placeholder();
  }
}