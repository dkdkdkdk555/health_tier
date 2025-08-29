import 'package:flutter/foundation.dart'; // @immutable 어노테이션을 위해 필요

/// 선택된 댓글/답글 정보를 담는 DTO
@immutable // 객체가 불변임을 나타내어 성능 최적화에 도움을 줍니다.
class SelectedReplyInfo {
  final int replyId; // 댓글/답글의 고유 ID
  final String comment; // 댓글/답글의 내용
  final String nickname; // 댓글/답글 작성자의 닉네임
  final bool isUpdate; // 이 댓글 정보가 수정 용도로 사용되는지 여부
  final bool isReReply; // 답글에 답글을 다는 경우 인지
  final int? fcmRecieveUserId;

  const SelectedReplyInfo({
    required this.replyId,
    required this.comment,
    required this.nickname,
    this.isUpdate = false, // 기본값은 false (일반 답글 작성용)
    this.isReReply = false,
    this.fcmRecieveUserId
  });

  // 객체의 동일성(Equality)을 비교하기 위해 operator ==와 hashCode를 오버라이드합니다.
  // 이 부분이 없으면 객체의 메모리 주소로만 비교되어, 내용이 같아도 다른 객체로 인식될 수 있습니다.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // 동일한 인스턴스면 true
    return other is SelectedReplyInfo && // 타입이 SelectedReplyInfo이고
        other.replyId == replyId && // 모든 필드값이 같으면 true
        other.comment == comment &&
        other.nickname == nickname &&
        other.isUpdate == isUpdate &&
        other.isReReply == isReReply &&
        other.fcmRecieveUserId == fcmRecieveUserId;
  }

  @override
  int get hashCode =>
      replyId.hashCode ^ comment.hashCode ^ nickname.hashCode ^ isUpdate.hashCode ^ isReReply.hashCode;

}
