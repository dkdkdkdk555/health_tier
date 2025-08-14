class APIServer{
  static const baseUrl = 'http://192.168.0.37:8080';
}

class FeedAPI {
  static const base = '/cmu/feed';

  static const getFeeds = '$base/feeds';
  static const isThereNewFeed = '$base/isThereNewFeed';
  static const getCategories = '$base/categories';
  static const getFeed = '$base/';
  static const getReplies = '/reply/';
  static const getSameCategoryFeeds = '$base/sameCategoryFeeds';
  static const getUsersFeeds = '$base/users';
  static const search = '$base/search';
  static increaseViewCount(int id) => '$base/$id/view';

}
 
class FeedCudAPI {
  static const base = '/cud/cmu/feed';

  static const uploadImages = '$base/images/upload-multiple';
  static const createFeed = base; // POST
  static const updateFeed = base; // PUT
  static const getFeedWhenUpate = '$base/'; // GET
  static const certificate = '$base/certificate';
  static const like = '$base/like'; // post
  static const cancelLike = '$base/like'; // delete

  static const reportFeed = '/cud/report';
}

class ReplyCudAPI {
  static const base = '/cud/reply';

  static const writeReply = base; // POST
  static const updateReply = base; // PUT
  static const deleteReply = base; // DELETE
  static const likeReply = '$base/like'; // POST
  static const cancelLikeReply = '$base/like'; // DELETE

  static const reportReply = '/cud/report/reply';

}

class UserAPI {
  static const base = '/cmu/usr';

  static const getUserInfo = '$base/';
}


class UserCudAPI {
  static const base = '/cud/usr';

  static const getUserBadges = '$base/badges';
  static const backupStatusCheck = '$base/backup/status';
  static const backupRequest = '$base/backup';
  static const backupRestore = '$base/backup/restore';
}


class AuthAPI {
  static const base = '/auth';

  static const verifyToken = '$base/verify-token';
  static const refreshAccessToken = '$base/token/refresh';
  static const verifyValidTokenOrSigned = '$base/sns/verify';
  static const joinAndLoginWithSns = '$base/sns/join';
  static const checkNickname = '/check-nickname';
}