import 'package:my_app/model/cmu/feed/badge_info_dto.dart';

class ReplyResponseDto {
  final int id;
  final int userId;
  final String nickname;
  final String imgPath;
  final String ctnt;
  int likeCnt; // 좋아요 즉각반영을 위해 final 제거
  final String createDttm;
  final String displayDttm;
  bool isLiked; // 좋아요 즉각반영을 위해 final 제거
  final int? parentReplyId;
  final String? delYn;
  final List<ReplyResponseDto> children;
  final List<BadgeInfoDto>? badges;

  ReplyResponseDto({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.imgPath,
    required this.ctnt,
    required this.likeCnt,
    required this.createDttm,
    required this.displayDttm,
    required this.isLiked,
    required this.delYn,
    required this.parentReplyId,
    required this.children,
    this.badges,
  });

 factory ReplyResponseDto.fromJson(Map<String, dynamic> json) {
    return ReplyResponseDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      imgPath: json['imgPath'] as String? ?? '',
      ctnt: json['ctnt'] as String,
      likeCnt: json['likeCnt'] as int,
      createDttm: json['createDttm'] as String, // createDttm은 보통 null이 아닐 것이라 가정합니다.
      // displayDttm이 null일 경우를 대비해 `as String? ?? ''` 추가
      displayDttm: json['displayDttm'] as String? ?? '', 
      isLiked: json['isLiked'] as bool? ?? false,
      parentReplyId: json['parentReplyId'] as int?,
      delYn: json['delYn'] as String? ?? 'N',
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ReplyResponseDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      // badges 리스트가 null일 경우를 대비해 `as List<dynamic>?` 추가 및 `e`를 `Map<String, dynamic>`으로 명시적 캐스팅
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => BadgeInfoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ReplyResponseDto copyWith({
    int? id,
    int? userId,
    String? nickname,
    String? imgPath,
    String? ctnt,
    int? likeCnt,
    String? createDttm,
    String? displayDttm,
    bool? isLiked,
    int? parentReplyId,
    String? delYn,
    List<ReplyResponseDto>? children,
    List<BadgeInfoDto>? badges,
  }) {
    return ReplyResponseDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      imgPath: imgPath ?? this.imgPath,
      ctnt: ctnt ?? this.ctnt,
      likeCnt: likeCnt ?? this.likeCnt,
      createDttm: createDttm ?? this.createDttm,
      displayDttm: displayDttm ?? this.displayDttm,
      isLiked: isLiked ?? this.isLiked,
      parentReplyId: parentReplyId ?? this.parentReplyId,
      delYn: delYn ?? this.delYn,
      children: children ?? this.children,
      badges: badges ?? this.badges,
    );
  }
}
