class APIServer{
  static const baseUrl = 'http://192.168.0.16:8080';
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

}

class UserAPI {
  static const base = '/cmu/usr';

  static const getUserInfo = '$base/';
}

class AuthAPI {
  static const base = '/auth';

  static const verifyValidTokenOrSigned = '$base/sns/verify';
  static const joinAndLoginWithSns = '$base/sns/join';
}