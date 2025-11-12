import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/db_providers.dart' show deleteAllNotifications, selectAllNotifications;
import 'package:my_app/providers/notifier_provider.dart' show notificationNumsNotifierProvider;

class BlockHeader extends ConsumerStatefulWidget {
  final void Function(bool) onLoading;
  const BlockHeader({
    super.key,
    required this.onLoading
  });

  @override
  ConsumerState<BlockHeader> createState() => _BlockHeaderState();
}

class _BlockHeaderState extends ConsumerState<BlockHeader> {

  /// 전체 삭제
  Future<void> _deleteAllNotifications() async {
    widget.onLoading(true);

    await deleteAllNotifications(ref: ref);
    // 안읽은 갯수 0으로
    ref.read(notificationNumsNotifierProvider).changeNum(0);
    // selectAllNotifications 재빌드
    ref.invalidate(selectAllNotifications);

    // 잠깐 스피너 표시 후 OFF
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      widget.onLoading(false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(notificationNumsNotifierProvider.select((notifier) => notifier.num));
    return Container(
      width: 375,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 안 읽은 알람 n개
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500
              ),
              children: [
                const TextSpan(text: '안 읽은 알람 '),
                TextSpan(
                  text: unreadCount.toString(),
                  style: const TextStyle(color: Color(0xFFE56413)),
                ),
                const TextSpan(text: '개'),
              ],
            ),
          ),

          // 전체 삭제 (밑줄 있는 버튼)
          GestureDetector(
            onTap: () {
              // 전체 삭제 로직
              _deleteAllNotifications();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '전체 삭제',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 1), // 👈 텍스트와 밑줄 간격 조절
                Container(
                  height: 1.5,
                  width: 52,
                  color: const Color(0xFF777777),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
