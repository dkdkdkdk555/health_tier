import 'package:flutter/material.dart';

class ReplySupplyNotifier extends ChangeNotifier{
  Map<int, String> _pickReply = {};

  /// 현재 선택된 댓글 ID 반환 (없으면 0)
  int get selectedReplyId => _pickReply.keys.isNotEmpty ? _pickReply.keys.first : 0;
  /// 현재 선택된 댓글 내용 반환 (없으면 '')
  String get comment => _pickReply.values.isNotEmpty ? _pickReply.values.first : '';
  Map<int, String> get pickReply => _pickReply;

  /// replyId와 comment를 함께 설정
  void pickReplyInfo(int replyId, String comment) {
    // 값이 변경될 때만 반영
    if (_pickReply.isEmpty || _pickReply.keys.first != replyId || _pickReply.values.first != comment) {
      _pickReply = {replyId: comment};
      notifyListeners();
    }
  }

  /// 선택 초기화
  void disposeReplyState() {
    if (_pickReply.isNotEmpty) {
      _pickReply.clear();
      notifyListeners();
    }
  }
}