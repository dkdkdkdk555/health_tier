import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/notifier_provider.dart' show notificationNumsNotifierProvider;

class BlockHeader extends ConsumerStatefulWidget {
  const BlockHeader({
    super.key,
  });

  @override
  ConsumerState<BlockHeader> createState() => _BlockHeaderState();
}

class _BlockHeaderState extends ConsumerState<BlockHeader> {

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
                const TextSpan(text: '차단한 사용자 총'),
                TextSpan(
                  text: unreadCount.toString(),
                  style: const TextStyle(color: Colors.black54),
                ),
                const TextSpan(text: '명'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
