class FoodAnalysisResult {
  final String foodName;
  final String description;
  final double calories;
  final double protein;
  final double sugar;
  
  FoodAnalysisResult({
    required this.foodName,
    required this.description,
    required this.calories,
    required this.protein,
    required this.sugar,
  });

  // JSON 데이터를 Dart 객체로 변환
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['foodName'] as String,
      description: json['description'] as String,
      // API 응답의 숫자 필드가 double 또는 int로 올 수 있으므로, .toDouble()로 처리합니다.
      calories: (json['calories'] as num).toDouble(), 
      protein: (json['protein'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
    );
  }

  // Dart 객체를 JSON 데이터로 변환 (선택 사항: 서버로 다시 보낼 필요가 없다면 생략 가능)
  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'description': description,
      'calories': calories,
      'protein': protein,
      'sugar': sugar,
    };
  }
}