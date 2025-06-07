import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/category_model.dart';
import 'package:my_app/model/result.dart';

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

}