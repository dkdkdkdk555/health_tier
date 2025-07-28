import 'package:my_app/model/cmu/feed/user_weight_crtifi_dto.dart'; // UserWeightCrtifiDto 임포트 필요

class FeedDto {
  final int? id; // `id` 필드는 수정 시에만 필요하므로 nullable
  final int categoryId;
  final String title;
  final String ctnt; // content는 백엔드에서 `ctnt`로 사용됨
  final int? userId; // userId도 백엔드에서 Long 타입일 수 있으므로 Long으로 가정
  final String ctntPreview;
  final String imgPreview;
  final List<UserWeightCrtifiDto>? userWeights; // 중량인증시 (최대3개)

  FeedDto({
    this.id,
    required this.categoryId,
    required this.title,
    required this.ctnt,
    this.userId,
    required this.ctntPreview,
    required this.imgPreview,
    this.userWeights,
  });

  // JSON으로부터 FeedDto 객체를 생성하는 팩토리 생성자 (수동 매핑)
  factory FeedDto.fromJson(Map<String, dynamic> json) {
    // userWeights 필드 파싱: JSON 리스트를 UserWeightCrtifiDto 객체 리스트로 변환
    List<UserWeightCrtifiDto>? parsedUserWeights;
    if (json['userWeights'] != null) {
      parsedUserWeights = (json['userWeights'] as List)
          .map((i) => UserWeightCrtifiDto.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return FeedDto(
      id: json['id'] as int?,
      categoryId: json['categoryId'] as int,
      title: json['title'] as String,
      ctnt: json['ctnt'] as String,
      userId: json['userId'] as int?, // userId가 백엔드에서 null로 올 수도 있다면 int? 로 변경
      ctntPreview: json['ctntPreview'] as String,
      imgPreview: json['imgPreview'] as String,
      userWeights: parsedUserWeights,
    );
  }

  // FeedDto 객체를 JSON으로 변환하는 메서드 (수동 매핑)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'ctnt': ctnt,
      'userId': userId,
      'ctntPreview': ctntPreview,
      'imgPreview': imgPreview,
      // userWeights 필드 변환: 리스트가 null이 아니면 각 객체를 Map으로 변환
      'userWeights': userWeights?.map((e) => e.toJson()).toList(),
    };
  }

  // (선택 사항) toString 메서드 추가
  @override
  String toString() {
    return 'FeedDto(id: $id, categoryId: $categoryId, title: $title, '
           'ctnt: $ctnt, userId: $userId, ctntPreview: $ctntPreview, '
           'imgPreview: $imgPreview, userWeights: $userWeights)';
  }
}