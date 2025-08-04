import 'package:flutter/material.dart';

class ReplyCommentSupplyNotifier extends ChangeNotifier{
  String _comment = '';

  String get comment => _comment;

  void pickReplyComment(String comment){
    if(_comment != comment) {
      _comment = comment;
      notifyListeners();
    }
  }

  void disposeReplyState() {
    pickReplyComment('');
  }
}