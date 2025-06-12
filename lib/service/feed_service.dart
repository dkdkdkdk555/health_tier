import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/common/scroll_response.dart';
import 'package:my_app/model/cmu/feed/category_model.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';

class FeedService {
  final Dio dio;
  FeedService(this.dio);

  Future<Result<List<Category>>> getCategories() async {
    final response = await dio.get(FeedAPI.getCategories);
    return Result.fromJson(
      response.data,
      (json) => (json as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList(),
    );
  }

  Future<ScrollResponse<FeedPreviewDto>> getFeedList({
      String? category,
      String? hotYn,
      int? cursorId,
      int limit = 10,
  }) async {
    final response = await dio.get(
      FeedAPI.getFeeds,
      queryParameters: {
        if (category != null) 'category': category,
        if (hotYn != null) 'hotYn': hotYn,
        if (cursorId != null) 'cursorId': cursorId,
        'limit': limit,
      },
    );

    return ScrollResponse.fromJson(
      response.data,
      (json) => FeedPreviewDto.fromJson(json),
    );
  }

}