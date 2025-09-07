import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/model/cmu/feed/category_model.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;

class CategoryTopBar extends ConsumerStatefulWidget {
  final bool isSpread;
  final VoidCallback onToggleSpread;
  final void Function({required int index}) onCategoryChange;
  final void Function({required bool hotYn}) onHotFeedBtnClick;
  final int selectedCategoryId;

  const CategoryTopBar({
    super.key,
    required this.isSpread,
    required this.onToggleSpread,
    required this.onCategoryChange,
    required this.onHotFeedBtnClick,
    required this.selectedCategoryId,
  });

  @override
  ConsumerState<CategoryTopBar> createState() => _CategoryTopBarState();
}

class _CategoryTopBarState extends ConsumerState<CategoryTopBar> {
  bool isBestFeedTap = false;
  late int selectedCategoryId;
  List modifiedCategoriesCollapse = [];

  late double htio;
  late double wtio;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    final categoriesAsync = ref.watch(getFeedCategories);

    return Container(
      padding: EdgeInsets.only(
        left: 20 * wtio,
        right: 20 * wtio,
        top: 16 * htio,
        bottom: 8 * htio,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          if (!widget.isSpread) ...[
            bestFeed(),
            borderLine(),
            buildCategoryCollapsed(categoriesAsync)
          ] else ...[
            buildCategoryExpanded(categoriesAsync)
          ],
          if (modifiedCategoriesCollapse.isNotEmpty) spreadBtn()
        ],
      ),
    );
  }

  Widget buildCategoryExpanded(
      AsyncValue<Result<List<Category>>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        final modifiedCategories = [
          Category(id: 0, name: '전체'),
          ...categories.data,
        ];

        final firstRowCategories = modifiedCategories.take(3).toList();
        final secondRowCategories = modifiedCategories.skip(3).toList();

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  bestFeed(),
                  borderLine(),
                  ...firstRowCategories.map(makeCategory),
                ],
              ),
              SizedBox(height: 8 * htio),
              if (secondRowCategories.isNotEmpty)
                Row(
                  children: secondRowCategories.map(makeCategory).toList(),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, stack) =>
          const Center(child: Text('카테고리 목록 로드 중 오류가 발생했습니다.')),
    );
  }

  Widget buildCategoryCollapsed(
      AsyncValue<Result<List<Category>>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        modifiedCategoriesCollapse = [
          Category(id: 0, name: '전체'),
          ...categories.data,
        ];
        return Expanded(
          child: SizedBox(
            height: 34 * htio,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: modifiedCategoriesCollapse.length,
              separatorBuilder: (_, __) => SizedBox(width: 0 * wtio),
              itemBuilder: (context, index) {
                final category = modifiedCategoriesCollapse[index];
                return GestureDetector(child: makeCategory(category));
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, stack) => const Center(child: Text('')),
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
        padding: EdgeInsets.symmetric(
          horizontal: 12 * wtio,
          vertical: 8 * htio,
        ),
        margin: EdgeInsets.only(right: 4 * wtio),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1 * wtio,
              color: isSelected
                  ? const Color(0xFF0D85E7)
                  : const Color(0xFFDDDDDD),
            ),
            borderRadius: BorderRadius.circular(99 * wtio),
          ),
        ),
        child: Text(
          category.name,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF0D85E7)
                : const Color(0xFF333333),
            fontSize: 12 * htio,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Align borderLine() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8 * wtio),
        width: 1 * wtio,
        height: 24 * htio,
        decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
      ),
    );
  }

  Widget spreadBtn() {
    return GestureDetector(
      onTap: () async {
        if (!widget.isSpread) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
        widget.onToggleSpread();
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 32 * wtio,
          height: 32 * htio,
          margin: EdgeInsets.only(left: 8 * wtio, top: 1 * htio),
          child: SvgPicture.asset(
            widget.isSpread
                ? 'assets/widgets/category_fold_btn.svg'
                : 'assets/widgets/category_spread_btn.svg',
          ),
        ),
      ),
    );
  }

  Widget bestFeed() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isBestFeedTap = !isBestFeedTap;
          widget.onHotFeedBtnClick(hotYn: isBestFeedTap);
        });
      },
      child: Container(
        height: 34 * htio,
        padding: EdgeInsets.symmetric(
          horizontal: 12 * wtio,
          vertical: 8 * htio,
        ),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1 * wtio,
              color: isBestFeedTap
                  ? const Color(0xFF0D85E7)
                  : const Color(0xFFDDDDDD),
            ),
            borderRadius: BorderRadius.circular(99 * wtio),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14 * wtio,
              height: 14 * htio,
              child: SvgPicture.asset('assets/icons/best.svg'),
            ),
            SizedBox(width: 2 * wtio),
            Text(
              '지금 뜨는',
              style: TextStyle(
                color: isBestFeedTap
                    ? const Color(0xFF0D85E7)
                    : const Color(0xFF333333),
                fontSize: 12 * htio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
