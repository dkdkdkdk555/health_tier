class APIServer{
  static const baseUrl = 'http://192.168.0.8:8080';
}

class FeedAPI {
  static const base = '/cmu/feed';

  static const getFeeds = '$base/feeds';
  static const isThereNewFeed = '$base/isThereNewFeed';
  static const getCategories = '$base/categories';
  static const getFeed = '$base/';

  static const getReplies = '/reply/';

  static const getSameCategoryFeeds = '$base/sameCategoryFeeds';
}
