import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/common/error_widget.dart';

class MyBadge extends ConsumerWidget {
  const MyBadge({super.key});

  static const todayBadgeIds = ['today10', 'today30', 'today100', 'today365'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    
    final badgesAsync = ref.watch(userBadgeListProvider);

    return badgesAsync.when(
      data: (badgesResult) {
        final badges = badgesResult.data;

        final weightBadges = badges.where((b) => b.badgeType == 'weight').toList();
        final todayBadges = badges.where((b) => b.badgeType == 'today').toList();

        return Column(
          children: [
            _buildHeader('중량 뱃지', htio, wtio),
            _buildWeightBadgeList(weightBadges, htio, wtio),
            _buildHeader('오운완 뱃지', htio, wtio),
            _buildTodayBadgeList(todayBadges, htio, wtio),
          ],
        );
      },
      error: (error, stackTrace) {
        return const ErrorContentWidget(mainText: '뱃지를 불러오는 중 오류가 발생했습니다',);
      },
      loading: () {
        return const Center(child: AppLoadingIndicator());
      },
    );
  }

  Widget _buildHeader(String title, double htio, double wtio) {
    return Container(
      width: double.infinity,
      height: 86 * htio,
      padding: EdgeInsets.only(
        top: 48 * htio,
        left: 20 * wtio,
        right: 20 * wtio,
        bottom: 8 * htio,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20 * htio,
              fontFamily: 'Pretendard',
              height: 0.07 * htio,
            ),
          ),
        ],
      ),
    );
  }

  // 오운완 뱃지 (today10,30,100,365 항상 표시)
  Widget _buildTodayBadgeList(List<BadgeInfoDto> owned, double htio, double wtio) {
    final ownedIds = owned.map((b) => b.badgeId).toSet();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16 * wtio,
        runSpacing: 20 * htio,
        children: todayBadgeIds.map((id) {
          final isOwned = ownedIds.contains(id);
          return _buildBadgeItem(
            id: id,
            name: _todayName(id),
            isOwned: isOwned,
            htio: htio,
            wtio: wtio,
          );
        }).toList(),
      ),
    );
  }

  // 중량 뱃지
  Widget _buildWeightBadgeList(List<BadgeInfoDto> owned, double htio, double wtio) {
    // 획득한 중량 중 최대치
    int maxOwned = 0;
    for (final b in owned) {
      final parsed = _parseWeight(b.badgeId);
      if (parsed != null && parsed > maxOwned) {
        maxOwned = parsed;
      }
    }

    // 전체 weight badge id 리스트가 있다고 가정 (예: 300~800)
    final allWeightIds = ['weight300', 'weight400', 'weight500', 'weight600', 'weight700', 'weight800'];
    final allWeightTitle = ['삼대삼백', '삼대사백', '삼대오백', '삼대육백', '삼대칠백', '삼대팔백'];

    final ownedIds = owned.map((b) => b.badgeId).toSet();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24 * htio),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16 * wtio,
        runSpacing: 20 * htio,
        children: allWeightIds.map((id) {
          final isOwned = ownedIds.contains(id);
          // final weightNum = _parseWeight(id) ?? 0;

          // 획득 못했지만 최고 뱃지보다 낮은 건 표시 안함 -> 걍 다 표시하자
          // if (!isOwned && weightNum <= maxOwned) {
          //   return const SizedBox.shrink();
          // }

          return _buildBadgeItem(
            id: id,
            name: allWeightTitle[allWeightIds.indexOf(id)],
            isOwned: isOwned,
            htio: htio,
            wtio: wtio
          );
        }).toList(),
      ),
    );
  }

   // 배지 아이템
  Widget _buildBadgeItem({
    required String id,
    required String name,
    required bool isOwned,
    required double htio,
    required double wtio,
  }) {
    return Container(
      width: 160 * wtio,
      height: 174 * htio,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1 * wtio, color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // 상단 이미지 영역
          Container(
            width: 160 * wtio,
            height: 120 * htio,
            color: const Color(0xFFF5F5F5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isOwned ? 1.0 : 0.2,
                  child: ColorFiltered(
                    colorFilter: isOwned
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.mode(Color(0xFFDDDDDD), BlendMode.saturation),
                    child: Image.asset(
                      'assets/image/badges/$id.png',
                      width: 100 * htio,
                      height: 100 * htio,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 하단 텍스트 영역
          Container(
            width: 160 * wtio,
            height: 52 * htio,
            color: Colors.white,
            alignment: Alignment.center,
            child: Text(
              name,
              style: TextStyle(
                color: isOwned ? Colors.black : Colors.grey,
                fontSize: 16 * htio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // today badge 이름 변환
  String _todayName(String id) {
    switch (id) {
      case 'today10':
        return '10회 인증';
      case 'today30':
        return '30회 인증';
      case 'today100':
        return '100회 인증';
      case 'today365':
        return '365회 인증';
      default:
        return id;
    }
  }

  // weight badge id -> 숫자 추출 (예: w300 → 300)
  int? _parseWeight(String id) {
    final match = RegExp(r'weight(\d+)').firstMatch(id);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
