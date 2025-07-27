class FeedDto {
  final int? id; // `id` 필드는 수정 시에만 필요하므로 nullable
  final int categoryId;
  final String title;
  final String ctnt; // content는 백엔드에서 `ctnt`로 사용됨
  final int? userId; // userId도 백엔드에서 Long 타입일 수 있으므로 Long으로 가정
  final String ctntPreview;
  final String imgPreview;

  FeedDto({
    this.id,
    required this.categoryId,
    required this.title,
    required this.ctnt,
    this.userId,
    required this.ctntPreview,
    required this.imgPreview,
  });

  // JSON으로부터 FeedDto 객체를 생성하는 팩토리 생성자 (수동 매핑)
  factory FeedDto.fromJson(Map<String, dynamic> json) {
    return FeedDto(
      id: json['id'] as int?, // id는 null일 수 있으므로 `as Long?` 사용
      categoryId: json['categoryId'] as int,
      title: json['title'] as String,
      ctnt: json['ctnt'] as String,
      userId: json['userId'] as int,
      ctntPreview: json['ctntPreview'] as String,
      imgPreview: json['imgPreview'] as String
    );
  }

  // FeedDto 객체를 JSON으로 변환하는 메서드 (수동 매핑)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // null일 경우 JSON에 null로 포함됨
      'categoryId': categoryId,
      'title': title,
      'ctnt': ctnt,
      'userId': userId,
      'ctntPreview': ctntPreview,
      'imgPreview' : imgPreview
    };
  }
}