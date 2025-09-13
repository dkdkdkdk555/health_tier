// 캐시 지우개

import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:my_app/providers/feed_providers.dart' show feedDetailProvider, feedParamsProvider, replyPaginationProvider;
import 'package:my_app/providers/user_cud_providers.dart' show authDioProvider;
import 'package:my_app/providers/usr_auth_providers.dart' show jwtTokenVerificationProvider, userAuthServiceAuthDioProvider;

class CmuInvalidateCollect {
  CmuInvalidateCollect();

  void cmuInvalidateCache(WidgetRef ref){
    // usr 관련
    ref.invalidate(authDioProvider);
    ref.invalidate(userAuthServiceAuthDioProvider);
    ref.invalidate(jwtTokenVerificationProvider);
    // feed 관련
    ref.invalidate(feedDetailProvider);
    ref.invalidate(replyPaginationProvider);
    ref.invalidate(feedParamsProvider);
  }
}