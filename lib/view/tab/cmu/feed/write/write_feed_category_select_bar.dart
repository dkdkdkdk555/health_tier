import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/category_model.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/providers/feed_providers.dart';

class WriteFeedCategorySelectBar extends ConsumerStatefulWidget {
  final void Function({required int index})onCategoryChange;
  final int selectedCategoryId;

  const WriteFeedCategorySelectBar({
    super.key,
    required this.onCategoryChange,
    required this.selectedCategoryId,
  });

  @override
  ConsumerState<WriteFeedCategorySelectBar> createState() => _WriteFeedCategorySelectBarState();
}

class _WriteFeedCategorySelectBarState extends ConsumerState<WriteFeedCategorySelectBar> {
  late int selectedCategoryId;

  @override
  void initState() {
    super.initState();
    selectedCategoryId =  widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(getFeedCategories);

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                  '카테고리 선택',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555555),
                  ),
                ),
            ),
          ),
          Row(
            children: [
                buildCategoryCollapsed(categoriesAsync)
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCollapsed(AsyncValue<Result<List<Category>>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        final modifiedCategories = [
          ...categories.data,
        ];
        return Expanded(
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: modifiedCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 0,),
              itemBuilder: (context, index) {
                final category = modifiedCategories[index];
                return makeCategory(category);
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('오류: \$err')),
    );
  }


  Widget makeCategory(Category category) {
    final isSelected = selectedCategoryId == category.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryId = category.id;
          widget.onCategoryChange(index: selectedCategoryId);
        });
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(right: 4),
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1,
                      color: isSelected ? const Color(0xFF0D85E7) : const Color(0xFFDDDDDD),
                  ),
                  borderRadius: BorderRadius.circular(99),
              ),
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 4,
                      children: [
                          Text(
                              category.name,
                              style: TextStyle(
                                  color: isSelected ? const Color(0xFF0D85E7) : const Color(0xFF333333),
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                              ),
                          ),
                      ],
                  ),
              ],
          ),
      ),
    );
  }
}


