import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/model/cmu/feed/category_model.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/providers/api_feed_providers.dart';

class CategoryTopBar extends ConsumerStatefulWidget {
  final double htio;
  final bool isSpread;
  final VoidCallback onToggleSpread;

  const CategoryTopBar({
    super.key,
    required this.htio,
    required this.isSpread,
    required this.onToggleSpread
  });

  @override
  ConsumerState<CategoryTopBar> createState() => _CategoryTopBarState();
}

class _CategoryTopBarState extends ConsumerState<CategoryTopBar> {

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(getFeedCategories);

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white
      ),
      child: Row(
        children: [
          if(!widget.isSpread) ...[
            const BestFeed(),
            borderLine(),
            buildCategoryCollapsed(categoriesAsync)
          ]else...[
            buildCategoryExpanded(categoriesAsync)
          ]
          ,spreadBtn()
        ],
      ),
    );
  }

  Widget buildCategoryExpanded(AsyncValue<Result<List<Category>>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        final modifiedCategories = [
          Category(id: 0, name: '전체'),
          ...categories.data,
        ];

        final firstRowCategories = modifiedCategories.take(3).toList(); // index 0~2
        final secondRowCategories = modifiedCategories.skip(3).toList(); // index 3~

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BestFeed(),
                  borderLine(),
                  ...firstRowCategories.map(makeCategory),
                ],
              ),
              const SizedBox(height: 8), // 줄 간 간격
              if (secondRowCategories.isNotEmpty)
                Row(
                  children: secondRowCategories.map(makeCategory).toList(),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('에러 발생: $err')),
    );
  }



  Widget buildCategoryCollapsed(AsyncValue<Result<List<Category>>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        final modifiedCategories = [
          Category(id: 0, name: '전체'), // 원하는 첫 번째 항목 추가
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
                return GestureDetector(
                  onTap: () {
                    // TODO: 카테고리 선택 처리
                  },
                  child: makeCategory(category)
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('오류: \$err')),
    );
  }


  Container makeCategory(Category category) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 4),
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                side: const BorderSide(
                    width: 1,
                    color: Color(0xFFDDDDDD),
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
                            style: const TextStyle(
                                color: Color(0xFF333333),
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
    );
  }

  Align borderLine() {
    return Align(
      alignment: Alignment.center,
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 1,
          height: 24,
          decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
      ),
    );
  }

  Widget spreadBtn(){
    return GestureDetector(
      onTap: () async {
        if (!widget.isSpread) {
          // 먼저 내부 애니메이션이 자연스럽게 줄어들도록 대기
          await Future.delayed(const Duration(milliseconds: 300));
        }
        widget.onToggleSpread(); // isSpread 상태 변경
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 8, top: 1),
          child: SvgPicture.asset(
            widget.isSpread ? 'assets/widgets/category_fold_btn.svg' : 'assets/widgets/category_spread_btn.svg',
          )
        ),
      ),
    );
  }
}


class BestFeed extends StatelessWidget {
  const BestFeed({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      width: 1,
                      color: Color(0xFFDDDDDD),
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
                      spacing: 2,
                      children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: SvgPicture.asset(
                              'assets/icons/best.svg'
                            )
                          ),
                          const Text(
                              '지금 뜨는',
                              style: TextStyle(
                                  color: Color(0xFF333333),
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
