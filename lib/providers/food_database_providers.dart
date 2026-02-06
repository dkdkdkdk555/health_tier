import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/diet/food_database_dto.dart';
import 'package:my_app/providers/feed_cud_providers.dart' show authDioProvider;
import 'package:my_app/service/food_database_service.dart';

/// FoodDatabaseService provider (auth Dio 주입)
final foodDatabaseServiceProvider = FutureProvider<FoodDatabaseService>((ref) async {
  final dio = await ref.watch(authDioProvider.future);
  return FoodDatabaseService(dio);
});

/// 식품 검색 provider (keyword -> FoodListDto 목록)
final foodSearchProvider = FutureProvider.autoDispose.family<List<FoodListDto>, String>((ref, keyword) async {
  final service = await ref.watch(foodDatabaseServiceProvider.future);
  return service.selectFoodList(keyword);
});

/// 식품 상세 조회 provider (id -> FoodDatabaseDto)
final foodDetailProvider = FutureProvider.autoDispose.family<FoodDatabaseDto?, int>((ref, id) async {
  final service = await ref.watch(foodDatabaseServiceProvider.future);
  return service.getFoodDetail(id);
});
