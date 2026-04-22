// 캐시 지우개

import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:my_app/providers/feed_providers.dart' show feedDetailProvider, feedPaginationProvider, feedParamsProvider, replyPaginationProvider;
import 'package:my_app/providers/user_cud_providers.dart' show authDioProvider, userBlockedListProvider, usrProfileImgProvider, usrSimpleInfoProvider;
import 'package:my_app/providers/usr_auth_providers.dart' show userAuthServiceAuthDioProvider;

class CmuInvalidateCollect {
  CmuInvalidateCollect();
  
  // 로그인-로그아웃 이후
  void cmuInvalidateCache(WidgetRef ref){
    // usr 관련
    ref.invalidate(authDioProvider);
    ref.invalidate(userAuthServiceAuthDioProvider);
    ref.invalidate(usrProfileImgProvider);
    // feed 관련
    ref.invalidate(feedDetailProvider);
    ref.invalidate(replyPaginationProvider);
    ref.invalidate(feedParamsProvider);
  }
  
  // 유저 정보 수정 이후
  void usrInfoUpdateInvalidateCache(WidgetRef ref) {
    ref.invalidate(usrSimpleInfoProvider);
    ref.invalidate(feedPaginationProvider);
    ref.invalidate(feedParamsProvider);
    ref.invalidate(usrProfileImgProvider);
  }

  // 피드관련만
  void cmuOnlyInvalidateCache(WidgetRef ref){
    // feed 관련
    ref.invalidate(feedDetailProvider);
    ref.invalidate(replyPaginationProvider);
    ref.invalidate(feedParamsProvider);
    ref.invalidate(userBlockedListProvider);
  }
  
}