import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/usr_create_feeds_sliver.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/usr_profile.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/usr_profile_app_bar_delegate.dart';

class CmuUsrProfile extends StatefulWidget {
  final int userId;
  const CmuUsrProfile({
    super.key,
    required this.userId,
  });

  @override
  State<CmuUsrProfile> createState() => _CmuUsrProfileState();
}

class _CmuUsrProfileState extends State<CmuUsrProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상단바 위 여백
          const TopBlankArea(),
          // 상단바
          SliverPersistentHeader(
            pinned: true,
            delegate: UsrProfileAppBarDelegate(ScreenRatio(context).heightRatio, widget.userId),
          ),
          // 프로필
          SliverToBoxAdapter(
            child: UsrProfile(userId: widget.userId,),
          ),
          // 작성한 글
          UsrCreateFeedsSliver(userId: widget.userId,)
        ],
      ),
    );
  }
}