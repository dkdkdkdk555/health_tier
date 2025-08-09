import 'package:flutter/material.dart';
import 'package:my_app/model/cmu/reply/selected_reply_info.dart';

class ReplySupplyNotifier extends ChangeNotifier {
  // 아무것도 선택되지 않았을 때는 null이 됩니다.
  SelectedReplyInfo? _selectedReplyInfo;

  /// 현재 선택된 댓글/답글 정보를 반환합니다. (없으면 null)
  /// 기존 `pickReply` getter를 유지하여 기존 코드와의 호환성을 높입니다.
  SelectedReplyInfo? get pickReply => _selectedReplyInfo;

  /// 현재 선택된 댓글 ID를 반환합니다. 선택된 댓글이 없으면 0을 반환합니다.
  int get selectedReplyId => _selectedReplyInfo?.replyId ?? 0;

  /// 현재 선택된 댓글 내용을 반환합니다. 선택된 댓글이 없으면 빈 문자열을 반환합니다.
  String get comment => _selectedReplyInfo?.comment ?? '';

  /// 현재 선택된 댓글 작성자의 닉네임을 반환합니다. 선택된 댓글이 없으면 빈 문자열을 반환합니다.
  String get nickname => _selectedReplyInfo?.nickname ?? '';

  /// 현재 선택된 댓글이 수정 용도인지 여부를 반환합니다. 선택된 댓글이 없으면 false를 반환합니다.
  bool get isUpdate => _selectedReplyInfo?.isUpdate ?? false;

  bool get isReReply => _selectedReplyInfo?.isReReply ?? false;

  /// 답글 또는 수정 대상 댓글/답글 정보를 설정합니다.
  ///
  /// [replyId] : 대상 댓글/답글의 고유 ID
  /// [comment] : 대상 댓글/답글의 내용
  /// [nickname] : 대상 댓글/답글 작성자의 닉네임
  /// [isUpdate] : 이 정보를 수정 용도로 사용할지 여부 (기본값은 `false`로, 답글 작성용입니다.)
  void pickReplyInfo(int replyId, String comment, String? nickname, {bool isUpdate = false, bool isReReply = false}) {
    final newInfo = SelectedReplyInfo(
      replyId: replyId,
      comment: comment,
      nickname: nickname ?? '',
      isUpdate: isUpdate,
      isReReply: isReReply,
    );

    // 이전 `_selectedReplyInfo`와 `newInfo`가 다를 경우에만 업데이트하고 리스너에게 알립니다.
    // 이는 불필요한 위젯 리빌드를 방지합니다.
    if (_selectedReplyInfo != newInfo) {
      _selectedReplyInfo = newInfo;
      notifyListeners();
    }
  }

  /// 선택된 댓글/답글 정보를 초기화합니다.
  /// (즉, 더 이상 답글을 달거나 수정할 대상이 없음을 나타냅니다.)
  void disposeReplyState() {
    if (_selectedReplyInfo != null) {
      _selectedReplyInfo = null; // null로 설정하여 선택 상태를 해제합니다.
      notifyListeners();
    }
  }
}
