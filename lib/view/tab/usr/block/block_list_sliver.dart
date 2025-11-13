import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/extension/cmu_invalidate_collect.dart' show CmuInvalidateCollect;
import 'package:my_app/model/usr/user/ht_user_block_dto.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/util/user_prefs.dart' show UserPrefs;
import 'package:my_app/view/common/error_widget.dart';

class BlockListSliver extends ConsumerStatefulWidget {
  const BlockListSliver({super.key});

  @override
  ConsumerState<BlockListSliver> createState() => _BlockListSliverState();
}

class _BlockListSliverState extends ConsumerState<BlockListSliver> {
  late int loginUserId;
  List<HtUserBlockDto> _blockList = [];

  @override
  void initState() {
    super.initState();
    loginUserId = UserPrefs.myUserId!;
  }

  @override
  Widget build(BuildContext context) {
    final blockListAsync = ref.watch(userBlockedListProvider);

    return blockListAsync.when(
      data: (result) {
        final list = result.data ?? [];

        // 초기 로딩 시 한 번만 저장
        if (_blockList.isEmpty) {
          _blockList = List.from(list);
        }

        final totalCount = _blockList.length;

        // 🔥 차단 사용자가 없는 경우 → SliverToBoxAdapter 직접 반환
        if (totalCount == 0) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  '차단한 사용자가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        // 🔥 차단 사용자가 있는 경우 → SliverList 반환
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "총 $totalCount명의 사용자를 차단했어요",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    _buildBlockItem(context, _blockList[index]),
                  ],
                );
              }
              return _buildBlockItem(context, _blockList[index]);
            },
            childCount: totalCount,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AppLoadingIndicator(),
          ),
        ),
      ),
      error: (err, stack) => const SliverToBoxAdapter(
        child: ErrorContentWidget(
          mainText: '차단 목록을 불러오는 중 오류가 발생했습니다.',
        ),
      ),
    );
  }

  /// 🔹 리스트 아이템 + 구분선 위젯
  Widget _buildBlockItem(BuildContext context, HtUserBlockDto user) {
    return Column(
      children: [
        Slidable(
          key: ValueKey(user.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) async {
                  final service = await ref.read(userCudServiceProvider.future);

                  try {
                    // 1) 차단 해제 API 호출
                    final result = await service.doBlockCancle(user.blockedUserId);

                    if (result == "success") {
                      // 2) UI 목록 즉시 제거
                      setState(() {
                        _blockList.removeWhere(
                          (element) => element.blockedUserId == user.blockedUserId,
                        );
                      });

                      // 3) 서버 최신 목록 다시 불러오도록 invalidate
                      CmuInvalidateCollect().cmuOnlyInvalidateCache(ref);

                      // 4) 사용자에게 안내 메시지
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("차단이 해제되었습니다.")),
                        );
                      }
                    } else {
                      throw Exception("API returned: $result");
                    }
                  } catch (e) {
                    // 실패 시 안내
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("차단 해제 실패: $e")),
                      );
                    }
                  }
                },
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
                icon: Icons.cancel,
                label: '차단 해제',
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: ClipOval(
                child: user.blockedUserImgPath != null
                    ? Image.network(
                        user.blockedUserImgPath!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SvgPicture.asset(
                            'assets/widgets/default_user_profile.svg',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : SvgPicture.asset(
                        'assets/widgets/default_user_profile.svg',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(
              user.blockedUserNickname ?? "알 수 없는 사용자",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "차단날짜: ${user.createDttm}",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),

        // 🔹 얇은 구분선 추가
        Container(
          height: 0.4,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}
