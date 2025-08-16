import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';

class UsrAppBarPreferredsize extends StatelessWidget implements PreferredSizeWidget {
  final String centerText;
  const UsrAppBarPreferredsize({
    super.key,
    required this.centerText
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
              height: 44,
            ),
        CmuBasicAppBar(centerText: centerText),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(48);
}