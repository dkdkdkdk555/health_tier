class Weight3Info {
  final String pose;
  final int weight;

  Weight3Info({
    required this.pose,
    required this.weight,
  });

  // JSON 맵으로부터 객체를 생성하는 팩토리 생성자
  factory Weight3Info.fromJson(Map<String, dynamic> json) {
    return Weight3Info(
      pose: json['pose'] as String,
      weight: json['weight'] as int,
    );
  }

  // 객체를 JSON 맵으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'pose': pose,
      'weight': weight,
    };
  }
}