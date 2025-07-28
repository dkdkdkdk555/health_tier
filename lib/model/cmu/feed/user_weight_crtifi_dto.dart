class UserWeightCrtifiDto {
  String? weightType; 
  int? weightKg; 

  // 기본 생성자 (선택적 매개변수)
  UserWeightCrtifiDto({
    this.weightType,
    this.weightKg,
  });

  // JSON 데이터를 Dart 객체로 변환하기 위한 팩토리 생성자
  factory UserWeightCrtifiDto.fromJson(Map<String, dynamic> json) {
    return UserWeightCrtifiDto(
      weightType: json['weightType'] as String?,
      weightKg: json['weightKg'] as int?,
    );
  }

  // Dart 객체를 JSON 데이터로 변환하기 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'weightType': weightType,
      'weightKg': weightKg,
    };
  }

  // (선택 사항) toString 메서드를 오버라이드하여 객체를 문자열로 표현
  @override
  String toString() {
    return 'UserWeightCrtifiDto(weightType: $weightType, weightKg: $weightKg)';
  }
}