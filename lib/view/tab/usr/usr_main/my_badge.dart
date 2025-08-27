import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/providers/user_cud_providers.dart';

class MyBadge extends ConsumerWidget {
  const MyBadge({super.key});

  static const todayBadgeIds = ['today10', 'today30', 'today100', 'today365'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgeListProvider);

    return badgesAsync.when(
      data: (badgesResult) {
        final badges = badgesResult.data;

        final weightBadges = badges.where((b) => b.badgeType == 'weight').toList();
        final todayBadges = badges.where((b) => b.badgeType == 'today').toList();

        return Column(
          children: [
            _buildHeader('오운완 뱃지'),
            _buildTodayBadgeList(todayBadges),
            _buildHeader('중량 뱃지'),
            _buildWeightBadgeList(weightBadges),
          ],
        );
      },
      error: (error, stackTrace) {
        return const Center(child: Text("뱃지를 불러오는 중 오류가 발생했습니다."));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
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

  // 오운완 뱃지 (today10,30,100,365 항상 표시)
  Widget _buildTodayBadgeList(List<BadgeInfoDto> owned) {
    final ownedIds = owned.map((b) => b.badgeId).toSet();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 24,
        children: todayBadgeIds.map((id) {
          final isOwned = ownedIds.contains(id);
          return _buildBadgeItem(
            id: id,
            name: _todayName(id),
            isOwned: isOwned,
          );
        }).toList(),
      ),
    );
  }

  // 중량 뱃지
  Widget _buildWeightBadgeList(List<BadgeInfoDto> owned) {
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

    final ownedIds = owned.map((b) => b.badgeId).toSet();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 24,
        children: allWeightIds.map((id) {
          final isOwned = ownedIds.contains(id);
          final weightNum = _parseWeight(id) ?? 0;

          // 획득 못했지만 최고 뱃지보다 낮은 건 표시 안함
          if (!isOwned && weightNum <= maxOwned) {
            return const SizedBox.shrink();
          }

          return _buildBadgeItem(
            id: id,
            name: "${weightNum}kg",
            isOwned: isOwned,
          );
        }).toList(),
      ),
    );
  }

  // 배지 아이템 (획득 여부에 따라 색/흑백)
  Widget _buildBadgeItem({
    required String id,
    required String name,
    required bool isOwned,
  }) {
    return SizedBox(
      width: 101,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/widgets/$id.svg',
            width: 101,
            height: 100,
            fit: BoxFit.contain,
            colorFilter: isOwned 
              ? null
              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              color: isOwned ? Colors.black : Colors.grey,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.5,
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
        return '10일 연속';
      case 'today30':
        return '30일 연속';
      case 'today100':
        return '100일 연속';
      case 'today365':
        return '365일 연속';
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
