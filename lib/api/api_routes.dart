class APIServer{
  static const baseUrl = 'http://192.168.0.25:8080';
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

class FeedCudAPI {
  static const base = '/cud/cmu/feed';

  static const uploadImages = '$base/images/upload-multiple';
  static const createFeed = base; // POST
  static const updateFeed = base; // PUT
  static const getFeedWhenUpate = '$base/'; // GET
}

class UserAPI {
  static const base = '/cmu/usr';

  static const getUserInfo = '$base/';
}

class AuthAPI {
  static const base = '/auth';

  static const verifyToken = '/verify-token';
  static const verifyValidTokenOrSigned = '$base/sns/verify';
  static const joinAndLoginWithSns = '$base/sns/join';
  static const checkNickname = '/check-nickname';
}