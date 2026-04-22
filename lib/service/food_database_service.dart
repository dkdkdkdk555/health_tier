import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart' show FoodDatabaseAPI;
import 'package:my_app/model/diet/food_database_dto.dart';

class FoodDatabaseService {
  final Dio dio;
  FoodDatabaseService(this.dio);

  /// 식품 검색 (keyword -> id, foodName 목록)
  Future<List<FoodListDto>> selectFoodList(String keyword) async {
    final response = await dio.get(
      FoodDatabaseAPI.list,
      queryParameters: {'keyword': keyword},
    );
    final List<dynamic> dataList = response.data['data'] ?? [];
    return dataList.map((e) => FoodListDto.fromJson(e)).toList();
  }

  /// 식품 상세 조회 (id -> 영양성분 전체)
  Future<FoodDatabaseDto?> getFoodDetail(int id) async {
    final response = await dio.get(FoodDatabaseAPI.detail(id));
    final data = response.data['data'];
    if (data == null) return null;
    return FoodDatabaseDto.fromJson(data);
  }
}
