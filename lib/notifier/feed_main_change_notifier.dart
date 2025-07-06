import 'package:flutter/widgets.dart';

class FeedMainChangeNotifier extends ChangeNotifier{
  int _userId = 0;
  int _categoryId = 0;
  
  int get userId => _userId;
  int get categoryId => _categoryId;

  // userId 값을 변경하고 리스너들에게 알리는 메서드
  void changeUserIdValue(int userId) {
    if (_userId != userId) { // 불필요한 업데이트 방지
      _userId = userId;
      notifyListeners(); // 이 메서드를 호출해야 UI가 업데이트됩니다.
    }
  }

  // categoryId 값을 변경하는 메서드 (예시)
  void changeCategoryId(int categoryId){
    if (_categoryId != categoryId){
      _categoryId = categoryId;
      notifyListeners();
    }
  }
}