import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/api_feed_providers.dart';

class CategoryTopBar extends ConsumerStatefulWidget {
  final double htio;
  const CategoryTopBar({
    super.key,
    required this.htio
  });

  @override
  ConsumerState<CategoryTopBar> createState() => _CategoryTopBarState();
}

class _CategoryTopBarState extends ConsumerState<CategoryTopBar> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(getFeedCategories);

    return categoriesAsync.when(
      data: (categories) {
        return SizedBox(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.count,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories.data[index];
              return GestureDetector(
                onTap: () {
                  // TODO: 카테고리 선택 처리
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('오류: \$err')),
    );
  }
}
