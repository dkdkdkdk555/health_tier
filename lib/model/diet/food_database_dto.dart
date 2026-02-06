class FoodListDto {
  final int id;
  final String foodName;

  FoodListDto({required this.id, required this.foodName});

  factory FoodListDto.fromJson(Map<String, dynamic> json) {
    return FoodListDto(
      id: json['id'],
      foodName: json['foodName'] ?? '',
    );
  }
}

class FoodDatabaseDto {
  final int id;
  final String foodName;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final double sugar;
  final double totalWeight;

  FoodDatabaseDto({
    required this.id,
    required this.foodName,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.sugar,
    required this.totalWeight,
  });

  factory FoodDatabaseDto.fromJson(Map<String, dynamic> json) {
    return FoodDatabaseDto(
      id: json['id'] ?? 0,
      foodName: json['foodName'] ?? '',
      kcal: (json['kcal'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
    );
  }
}
