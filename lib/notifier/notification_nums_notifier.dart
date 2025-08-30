
import 'package:flutter/foundation.dart';

class NotificationNumsNotifier extends ChangeNotifier{
  int _num = 0;

  int get num => _num;

  void changeNum(int notifiNum){
    if(_num != notifiNum) {
      _num = notifiNum;
      notifyListeners();
    }
  }
}
